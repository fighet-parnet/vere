{-# OPTIONS_GHC -Wwarn #-}

module Vere.Serf where

import ClassyPrelude
import Control.Lens

import Data.Void
import Noun
import System.Process
import Vere.Pier.Types

import Data.ByteString        (hGet)
import Data.ByteString.Unsafe (unsafeUseAsCString)
import Foreign.Marshal.Alloc  (alloca)
import Foreign.Ptr            (castPtr)
import Foreign.Storable       (peek, poke)
import System.Exit            (ExitCode)

import qualified Data.ByteString.Unsafe as BS
import qualified Urbit.Time             as Time


--------------------------------------------------------------------------------


{-
    TODO:
      - getInput   :: STM (Writ ())
      - onComputed :: Writ [Effect] -> STM ()
      - onExit     :: Serf -> IO ()
      - task       :: Async ()
-}
data Serf = Serf
  { sendHandle :: Handle
  , recvHandle :: Handle
  , process    :: ProcessHandle
  }


--------------------------------------------------------------------------------

{-
    TODO Think about how to handle process exit
    TODO Tear down subprocess on exit? (terminiteProcess)
    TODO `config` is a stub, fill it in.
-}
startSerfProcess :: FilePath -> IO Serf
startSerfProcess pier =
  do
    (Just i, Just o, _, p) <- createProcess pSpec
    pure (Serf i o p)
  where
    chkDir  = traceShowId pier
    diskKey = ""
    config  = "0"
    args    = [chkDir, diskKey, config]
    pSpec   = (proc "urbit-worker" args)
                { std_in = CreatePipe
                , std_out = CreatePipe
                }

kill :: Serf -> IO ExitCode
kill w = do
  terminateProcess (process w)
  waitForProcess (process w)

work :: Word64 -> Jam -> Atom
work id (Jam a) = jam $ toNoun (Cord "work", id, a)

newtype Job = Job Void
  deriving newtype (Eq, Show, ToNoun, FromNoun)

type EventId = Word64

--------------------------------------------------------------------------------

data Order
    = OBoot LogIdentity
    | OExit Word8
    | OSave EventId
    | OWork EventId Atom
  deriving (Eq, Ord, Show)

-- XX TODO Support prefixes in deriveNoun
instance ToNoun Order where
  toNoun (OBoot id)  = toNoun (Cord "boot", id)
  toNoun (OExit cod) = toNoun (Cord "exit", cod)
  toNoun (OSave id)  = toNoun (Cord "save", id)
  toNoun (OWork w a) = toNoun (Cord "work", w, a)

type Play = Maybe (EventId, Mug, ShipId)

data Plea
    = Play Play
    | Work EventId Mug Job
    | Done EventId Mug [(Path, Eff)]
    | Stdr EventId Cord
    | Slog EventId Word32 Tank
  deriving (Eq, Show)

deriveNoun ''Plea

--------------------------------------------------------------------------------

type CompletedEventId = Word64
type NextEventId      = Word64
type SerfState        = (EventId, Mug)
type ReplacementEv    = (EventId, Mug, Job)
type WorkResult       = (EventId, Mug, [(Path, Eff)])
type SerfResp         = (Either ReplacementEv WorkResult)

-- Exceptions ------------------------------------------------------------------

data SerfExn
    = BadComputeId EventId WorkResult
    | BadReplacementId EventId ReplacementEv
    | UnexpectedPlay EventId Play
    | BadPleaAtom Atom
    | BadPleaNoun Noun Text
    | ReplacedEventDuringReplay EventId ReplacementEv
    | ReplacedEventDuringBoot   EventId ReplacementEv
    | EffectsDuringBoot         EventId [(Path, Eff)]
    | SerfConnectionClosed
    | UnexpectedPleaOnNewShip Plea
    | InvalidInitialPlea Plea
  deriving (Show)

instance Exception SerfExn

-- Utils -----------------------------------------------------------------------

printTank :: Word32 -> Tank -> IO ()
printTank pri t = print "[SERF] tank"

guardExn :: Exception e => Bool -> e -> IO ()
guardExn ok = unless ok . throwIO

fromJustExn :: Exception e => Maybe a -> e -> IO a
fromJustExn Nothing  exn = throwIO exn
fromJustExn (Just x) exn = pure x

fromRightExn :: Exception e => Either a b -> (a -> e) -> IO b
fromRightExn (Left m)  exn = throwIO (exn m)
fromRightExn (Right x) _   = pure x

--------------------------------------------------------------------------------

sendAndRecv :: Serf -> EventId -> Order -> IO SerfResp
sendAndRecv w eventId order =
  do
    traceM ("sendAndRecv: " <> show eventId)
    sendOrder w order
    res <- loop
    traceM ("sendAndRecv.done " <> show res)
    pure res
  where
    produce :: WorkResult -> IO SerfResp
    produce (i, m, o) = do
      guardExn (i == eventId) (BadComputeId eventId (i, m, o))
      pure $ Right (i, m, o)

    replace :: ReplacementEv -> IO SerfResp
    replace (i, m, j) = do
      guardExn (i == eventId) (BadReplacementId eventId (i, m, j))
      pure (Left (i, m, j))

    loop :: IO SerfResp
    loop = recvPlea w >>= \case
      Play p       -> throwIO (UnexpectedPlay eventId p)
      Done i m o   -> produce (i, m, o)
      Work i m j   -> replace (i, m, j)
      Stdr _ cord  -> putStrLn (pack ("[SERF] " <> cordString cord)) >> loop
      Slog _ pri t -> printTank pri t >> loop

sendOrder :: Serf -> Order -> IO ()
sendOrder w o = sendAtom w $ jam $ toNoun o

bootFromSeq :: Serf -> BootSeq -> IO [Order]
bootFromSeq serf (BootSeq ident nocks ovums) = do
    handshake serf ident >>= \case
        (1, Mug 0) -> pure ()
        _          -> error "ship already booted"

    res <- loop [] 1 (Mug 0) seq

    OWork lastEv _ : _ <- evaluate (reverse res)

    traceM "Requesting snapshot"
    sendOrder serf (OSave lastEv)

    traceM "Requesting shutdown"
    sendOrder serf (OExit 0)

    pure res

  where
    loop :: [Order] -> EventId -> Mug -> [EventId -> Mug -> Time.Wen -> Order]
         -> IO [Order]
    loop acc eId lastMug []     = pure $ reverse acc
    loop acc eId lastMug (x:xs) = do
        wen <- Time.now
        let order = x eId lastMug wen
        sendAndRecv serf eId order >>= \case
            Left badEv          -> throwIO (ReplacedEventDuringBoot eId badEv)
            Right (id, mug, []) -> loop (order : acc) (eId+1) mug xs
            Right (id, mug, fx) -> throwIO (EffectsDuringBoot eId fx)

    seq :: [EventId -> Mug -> Time.Wen -> Order]
    seq = fmap muckNock nocks <> fmap muckOvum ovums
      where
        muckNock nok eId mug _   = OWork eId $ jam $ toNoun (mug, nok)
        muckOvum ov  eId mug wen = OWork eId $ jam $ toNoun (mug, wen, ov)

-- the ship is booted, but it is behind. shove events to the worker until it is
-- caught up.
replayEvents :: Serf
             -> SerfState
             -> LogIdentity
             -> EventId
             -> (EventId -> Word64 -> IO (Vector (EventId, Atom)))
             -> IO (EventId, Mug)
replayEvents w (wid, wmug) ident lastCommitedId getEvents = do
  traceM ("replayEvents: " <> show wid <> " " <> show wmug)

  when (wid == 1) (sendOrder w $ OBoot ident)

  vLast <- newIORef (wid, wmug)
  loop vLast wid

  res <- readIORef vLast
  traceM ("replayEvents.return " <> show res)
  pure res

  where
    -- Replay events in batches of 1000.
    loop vLast curEvent = do
      traceM ("replayEvents.loop: " <> show curEvent)
      let toRead = min 1000 (1 + lastCommitedId - curEvent)
      when (toRead > 0) $ do
        traceM ("replayEvents.loop.getEvents " <> show toRead)

        events <- getEvents curEvent toRead

        traceM ("got events " <> show (length events))

        for_ events $ \(eventId, event) -> do
          sendAndRecv w eventId (OWork eventId event) >>= \case
            Left ev            -> throwIO (ReplacedEventDuringReplay eventId ev)
            Right (id, mug, _) -> writeIORef vLast (id, mug)

        loop vLast (curEvent + toRead)


bootSerf :: Serf -> LogIdentity -> ByteString -> IO (EventId, Mug)
bootSerf w ident pill =
  do
    recvPlea w >>= \case
      Play Nothing -> pure ()
      x@(Play _)   -> throwIO (UnexpectedPleaOnNewShip x)
      x            -> throwIO (InvalidInitialPlea x)

    -- TODO: actually boot the pill
    undefined

    -- Maybe return the current event id ? But we'll have to figure that out
    -- later.
    pure undefined

type GetEvents = EventId -> Word64 -> IO (Vector (EventId, Atom))

{-
    Waits for initial plea, and then sends boot IPC if necessary.
-}
handshake :: Serf -> LogIdentity -> IO (EventId, Mug)
handshake serf ident = do
    (eventId, mug) <- recvPlea serf >>= \case
      Play Nothing          -> pure (1, Mug 0)
      Play (Just (e, m, _)) -> pure (e, m)
      x                     -> throwIO (InvalidInitialPlea x)

    traceM ("handshake: got plea! " <> show eventId <> " " <> show mug)

    when (eventId == 1) $ do
        sendOrder serf (OBoot ident)
        traceM ("handshake: Sent %boot IPC")

    pure (eventId, mug)

replay :: Serf -> LogIdentity -> EventId -> GetEvents -> IO (EventId, Mug)
replay w ident lastEv getEvents = do
    ws@(eventId, mug) <- recvPlea w >>= \case
      Play Nothing          -> pure (1, Mug 0)
      Play (Just (e, m, _)) -> pure (e, m)
      x                     -> throwIO (InvalidInitialPlea x)

    traceM ("got plea! " <> show eventId <> " " <> show mug)

    replayEvents w ws ident lastEv getEvents

workerThread :: Serf -> STM Ovum -> (EventId, Mug) -> IO (Async ())
workerThread w getEvent (evendId, mug) = async $ forever $ do
  ovum <- atomically $ getEvent

  currentDate <- Time.now

  let _mat = jam (undefined (mug, currentDate, ovum))

  undefined

  -- Writ (eventId + 1) Nothing mat
  -- -- assign a new event id.
  -- -- assign a date
  -- -- get current mug state
  -- -- (jam [mug event])
  -- sendAndRecv

requestSnapshot :: Serf -> IO ()
requestSnapshot w =  undefined

-- The flow here is that we start the worker and then we receive a play event
-- with the current worker state:
--
--  <- [%play ...]
--
-- Base on this, the main flow is
--

  --  [%work ] ->
  --  <- [%slog]
  --  <- [%slog]
  --  <- [%slog]
  --  <- [%work crash=tang]
  --  [%work ] ->  (replacement)
  --  <- [%slog]
  --  <- [%done]
--    [%work eventId mat]

--  response <- recvAtom w


-- Basic Send and Receive Operations -------------------------------------------

withWord64AsByteString :: Word64 -> (ByteString -> IO a) -> IO a
withWord64AsByteString w k = do
  alloca $ \wp -> do
    poke wp w
    bs <- BS.unsafePackCStringLen (castPtr wp, 8)
    k bs

sendLen :: Serf -> Int -> IO ()
sendLen s i = do
  traceM "sendLen.put"
  w <- evaluate (fromIntegral i :: Word64)
  withWord64AsByteString (fromIntegral i) (hPut (sendHandle s))
  traceM "sendLen.done"

sendAtom :: Serf -> Atom -> IO ()
sendAtom s a = do
  traceM "sendAtom"
  let bs = unpackAtom a
  sendLen s (length bs)
  hPut (sendHandle s) bs
  hFlush (sendHandle s)
  traceM "sendAtom.return ()"

packAtom :: ByteString -> Atom
packAtom = view (from atomBytes)

unpackAtom :: Atom -> ByteString
unpackAtom = view atomBytes

recvLen :: Serf -> IO Word64
recvLen w = do
  traceM "recvLen.wait"
  bs <- hGet (recvHandle w) 8
  traceM "recvLen.got"
  case length bs of
    -- This is not big endian safe
    8 -> unsafeUseAsCString bs (peek . castPtr)
    _ -> throwIO SerfConnectionClosed

recvBytes :: Serf -> Word64 -> IO ByteString
recvBytes w = do
  traceM "recvBytes"
  hGet (recvHandle w) . fromIntegral

recvAtom :: Serf -> IO Atom
recvAtom w = do
  traceM "recvAtom"
  len <- recvLen w
  bs <- recvBytes w len
  pure (packAtom bs)

cordString :: Cord -> String
cordString (Cord bs) = unpack $ decodeUtf8 bs

recvPlea :: Serf -> IO Plea
recvPlea w = do
  traceM "recvPlea"

  a <- recvAtom w
  traceM ("recvPlea.cue " <> show (length $ a ^. atomBytes))
  n <- fromRightExn (cue a) (const $ BadPleaAtom a)
  traceM "recvPlea.doneCue"
  p <- fromRightExn (fromNounErr n) (BadPleaNoun $ traceShowId n)

  traceM "recvPlea.done"

  -- TODO Hack!
  case p of
    Stdr e msg -> traceM ("[SERF] " <> cordString msg) >> recvPlea w
    _          -> pure p
