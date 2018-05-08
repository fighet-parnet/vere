/+  tester
=,  eyre
::
::::  libraries
::
|%
++  base64                                        :: rfc4648
  =+  [pad=& url=|]                               :: section 4 or 5
  |%
  ++  en                                          :: encode base64
    |=  tig=@
    ^-  cord
    =/  poc  (~(dif fo 3) 0 (met 3 tig))
    =/  pad  (lsh 3 poc (swp 3 tig))
    =/  cha
      ?:  url
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    %-  crip
    %-  flop
    %+  weld
      ?.(^pad ~ (reap poc '='))
    %+  slag  poc
    |-  ^-  tape
    ?~  pad  ~
    =/  d  (end 3 3 pad)
    :*  (cut 3 [(cut 0 [0 6] d) 1] cha)
        (cut 3 [(cut 0 [6 6] d) 1] cha)
        (cut 3 [(cut 0 [12 6] d) 1] cha)
        (cut 3 [(cut 0 [18 6] d) 1] cha)
        $(pad (rsh 3 3 pad))
    ==
  ::
  ++  de                                          :: decode base64
    |=  a=cord
    ^-  (unit @)
    %+  rush  a
    %+  cook  (cury swp 3)
    %+  bass  64
    %+  cook  welp
    ;~  plug
      %-  plus
      ;~  pose
        (cook |=(a=@ (sub a 'A')) (shim 'A' 'Z'))
        (cook |=(a=@ (sub a 'G')) (shim 'a' 'z'))
        (cook |=(a=@ (add a 4)) (shim '0' '9'))
        (cold 62 (just ?:(url '-' '+')))
        (cold 63 (just ?:(url '_' '/')))
      ==
      ?:  pad
        (stun 0^2 (cold %0 tis))
      =/  b  (~(dif fo 4) 0 (met 3 a))
      (cold (reap b %0) (easy ~))
    ==
  --
::
++  en-base64url                                        :: padding omitted
  ~(en base64 | &)                                      :: per rfc7515
::
++  de-base64url
  ~(de base64 | &)
::
++  asn1                                              ::  at least, a little
  =>  |%
      +=  spec
        $%  [%int p=@]
            [%oct p=@]
            [%nul ~]
            [%obj p=@]
            [%seq p=(list spec)]
        ==
      ::
      ++  obj                                         ::  constants (rfc4055)
        |%                                            ::
        ++  sha-256  0x1.0204.0365.0148.8660          :: 2.16.840.1.101.3.4.2.1
        --
      --
  ::
  |_  pec=spec
  ++  ren                                             ::  bytes
    ^-  (list @)
    =/  a  lem
    [tag (weld (len a) a)]
  ::
  ++  tag                                             ::  type tag
    ^-  @
    ?-  pec
      [%int *]   2
      [%oct *]   4
      [%nul *]   5
      [%obj *]   6
      [%seq *]  48    :: (con 0x20 16)
    ==
  ::
  ++  lem                                             ::  element bytes
    ^-  (list @)
    ?-  pec
      [%int *]  =/  a  (flop (rip 3 p.pec))     :: XX unsigned only!
                ?~  a  [0 ~]
                ?:((lte i.a 127) a [0 a])
      ::
      [%oct *]  (rip 3 p.pec)
      [%nul *]  ~
      [%obj *]  (rip 3 p.pec)
      ::
      [%seq *]  %-  zing
                |-  ^-  (list (list @))
                ?~  p.pec  ~
                :-  ren:.(pec i.p.pec)
                $(p.pec t.p.pec)
    ==
  ::
  ++  len                                             ::  length bytes
    |=  a=(list @)
    ^-  (list @)
    =/  b  (lent a)
    ?:  (lte b 127)
      [b ~]
    [(con 0x80 (met 3 b)) (flop (rip 3 b))]
  ::
  ++  decode
    %+  cook  |*(a=* `spec:asn1`a)
    ;~  pose
      %+  stag  %int
      %+  bass  256
      %+  sear
        |=  a=(list @)
        ^-  (unit (list @))
        ?~  a  ~
        ?:  ?=([@ ~] a)  `a
        ?.  =(0 i.a)  `a
        ?.((gth i.t.a 127) ~ `t.a)
      ;~(pfix (just `@`2) till)
      ::
      (stag %oct (boss 256 ;~(pfix (just `@`4) till)))
      (stag %nul (cold ~ ;~(plug (just `@`5) (just `@`0))))
      (stag %obj (boss 256 ;~(pfix (just `@`6) till)))
      ::
      %+  stag  %seq
      %+  sear
        |=(a=(list @) (rust a (star decode))) :: XX plus? curr?
      ;~(pfix (just `@`48) till)
    ==
  ::
  ++  till                                                ::  len-prefixed bytes
    |=  tub/nail
    ^-  (like (list @D))
    ?~  q.tub
      (fail tub)
    =*  fuz  i.q.tub
    =+  ^-  [nex=@ len=@]
      =/  faz  (end 0 7 fuz)
      ?:  =(0 (cut 0 [7 1] fuz))
        [0 faz]
      [faz (rep 3 (flop (scag faz t.q.tub)))]
    ?:  ?&  !=(0 nex)
            !=(nex (met 3 len))
        ==
      (fail tub)
    =/  zuf  (swag [nex len] t.q.tub)
    ?.  =(len (lent zuf))
      (fail tub)
    =/  zaf  [p.p.tub (add +(nex) q.p.tub)]
    [zaf `[zuf zaf (slag (add nex len) t.q.tub)]]
  --
::
++  rsa                                                 ::  unpadded!
  |%
  +=  key  [p=@ux q=@ux n=@ux e=@ux d=@ux]
  ++  elcm
    |=  [a=@ b=@]
    (div (mul a b) d:(egcd a b))
  ::
  ++  new-key
    =/  e  `@ux`65.537
    |=  [wid=@ eny=@]
    ^-  key
    =/  diw  (rsh 0 1 wid)
    =/  p=@ux  (ramp:number diw [3 5 ~] eny)
    =/  q=@ux  (ramp:number diw [3 5 ~] +(eny))
    =/  n=@ux  (mul p q)
    =/  d=@ux  (~(inv fo (elcm (dec p) (dec q))) e)
    [p q n e d]
  ::
  ++  der
    |%
    ++  en
      |%
      ++  pass  !!
      ++  ring
        |=  k=key
        ^-  @ux
        =;  pec
          (rep 3 ~(ren asn1 pec))
        :~  %seq
            [%int 0]
            [%int n.k]
            [%int e.k]
            [%int d.k]
            [%int p.k]
            [%int q.k]
            [%int (mod d.k (dec p.k))]
            [%int (mod d.k (dec q.k))]
            [%int (~(inv fo p.k) q.k)]
        ==
      --
    ++  de
      |%
      ++  pass  !!
      ++  ring
        |=  a=@
        ^-  (unit key)
        =/  b  (rush a decode:asn1)
        ?~  b  ~
        ?.  ?=([%seq *] u.b)  ~
        ?.  ?=  $:  [%int *]
                    [%int *]
                    [%int *]
                    [%int *]
                    [%int *]
                    [%int *]
                    *
                ==
            p.u.b
          ~
        =*  n  p.i.t.p.u.b
        =*  e  p.i.t.t.p.u.b
        =*  d  p.i.t.t.t.p.u.b
        =*  p  p.i.t.t.t.t.p.u.b
        =*  q  p.i.t.t.t.t.t.p.u.b
        `[p q n e d]
      --
    --
  ::
  ++  pem
    |%
    ++  en
      |%
      ++  pass  !!
      ++  ring
        |=  k=key
        ^-  wain
        :-  '-----BEGIN RSA PRIVATE KEY-----'
        =/  a  (en:base64 (ring:en:der k))
        |-  ^-  wain
        ?~  a
          ['-----END RSA PRIVATE KEY-----' ~]
        [(end 3 64 a) $(a (rsh 3 64 a))]
      --
    ++  de
      |%
      ++  pass  !!
      ++  ring
        |=  mep=wain
        ^-  (unit key)
        =/  a  (sub (lent mep) 2)
        ?~  mep  ~
        ?.  =('-----BEGIN RSA PRIVATE KEY-----' i.mep)  ~
        ?.  =('-----END RSA PRIVATE KEY-----' (snag a t.mep))  ~
        =/  b  (de:base64 (rap 3 (scag a t.mep)))
        ?~  b  ~
        (ring:de:der u.b)
      --
    --
  ::
  ++  en
    |=  [m=@ k=key]
    ~|  %rsa-len
    ?>  (lte (met 0 m) (met 0 n.k))
    (~(exp fo n.k) e.k m)
  ::
  ++  de
    |=  [m=@ k=key]
    :: XX assert rsa-len here too?
    =/  fu  (fu:number p.k q.k)
    (out.fu (exp.fu d.k (sit.fu m)))
  --
::
++  rs256
  |_  k=key:rsa
  ++  emsa        :: EMSA-PKCS1-v1_5
    |=  m=@
    =/  emlen  (met 3 n.k)
    =/  pec=spec:asn1
      :~  %seq
          [%seq [%obj sha-256:obj:asn1] [%nul ~] ~]
          [%oct (shax m)]
      ==
    =/  t=(list @)  ~(ren asn1 pec)
    =/  tlen  (lent t)
    ?:  (lth emlen (add 11 tlen))
      ~|(%emsa-too-short !!)
    =/  ps  (reap (sub emlen (add 3 tlen)) 0xff)
    %+  rep  3
    (flop (weld [0x0 0x1 ps] [0x0 t]))
  ::
  ++  sign  |=(m=@ (de:rsa (emsa m) k))
  ::
  ++  verify
    |=  [s=@ m=@]
    =((emsa m) (en:rsa s k))
  --
::
++  en-json-sort                                      ::  print json
  |^  |=([sor=$-(^ ?) val=json] (apex val sor ""))
  ::                                                  ::  ++apex:en-json:html
  ++  apex
    =,  en-json:html
    |=  {val/json sor/$-(^ ?) rez/tape}
    ^-  tape
    ?~  val  (weld "null" rez)
    ?-    -.val
        $a
      :-  '['
      =.  rez  [']' rez]
      !.
      ?~  p.val  rez
      |-
      ?~  t.p.val  ^$(val i.p.val)
      ^$(val i.p.val, rez [',' $(p.val t.p.val)])
   ::
        $b  (weld ?:(p.val "true" "false") rez)
        $n  (weld (trip p.val) rez)
        $s
      :-  '"'
      =.  rez  ['"' rez]
      =+  viz=(trip p.val)
      !.
      |-  ^-  tape
      ?~  viz  rez
      =+  hed=(jesc i.viz)
      ?:  ?=({@ $~} hed)
        [i.hed $(viz t.viz)]
      (weld hed $(viz t.viz))
   ::
        $o
      :-  '{'
      =.  rez  ['}' rez]
      =/  viz
        %+  sort  ~(tap by p.val)
        |=((pair) (sor (head p) (head q)))
      ?~  viz  rez
      !.
      |-  ^+  rez
      ?~  t.viz  ^$(val [%s p.i.viz], rez [':' ^$(val q.i.viz)])
      =.  rez  [',' $(viz t.viz)]
      ^$(val [%s p.i.viz], rez [':' ^$(val q.i.viz)])
    ==
  --
::
++  jwk
  |_  k=key:rsa
  ++  pass
    ^-  json
    :-  %o  %-  my  :~
      kty+s+'RSA'
      n+s+(en-base64url n.k)
      e+s+(en-base64url e.k)
    ==
  ++  ring  !!
  --
++  thumbprint
  |=  jon=json
  :: XX restrict keys to canonical set
  (en-base64url (shax `@`(crip `tape`(en-json-sort aor jon))))
::
++  from-json
  =,  dejs:format
  =/  json-purl  (su auri:de-purl:html)
  %-  ot
  :~  ['newAccount' json-purl]
      ['newNonce' json-purl]
      ['newOrder' json-purl]
      ['revokeCert' json-purl]
      ['keyChange' json-purl]
  ==
--
::
::::  acme state
::
|%
+=  move  [bone card]
+=  card  $%  [%hiss wire [~ ~] %httr %hiss hiss:eyre]
          ==
::
+=  nonce  @t
::
+=  directory                                           ::  ACME v2
  $:  reg/purl                                          ::  newAccount
      non/purl                                          ::  newNonce
      der/purl                                          ::  newOrder
      rev/purl                                          ::  revokeCert
      rek/purl                                          ::  keyChange
  ==
::
+=  state
  $:  dir=directory
      non=nonce
      kid=(unit @t)
      key=(unit key:rsa)
  ==
--
::
::::  acme app
::
=/  url=tape  "https://acme-staging-v02.api.letsencrypt.org/directory"
=/  bas=purl  (scan url auri:de-purl:html)
=|  mov=(list move)
|_  [bow=bowl:gall state]
::
++  this  .               :: XX #712
::
++  emit
  |=  car=card
  ~&  [%emit car]
  this(mov [[ost.bow car] mov])
::
++  abet
  [(flop mov) this(mov ~)]
::
++  jws-body
  |=  [url=purl bod=json]
  ^-  octs
  =*  enc  (corl en-base64url (corl crip (cury en-json-sort aor)))
  =/  payload=cord  (enc bod)
  =/  protect=cord
    %-  enc
    :-  %o  %-  my  :~
      alg+s+'RS256'
      nonce+s+non
      url+s+(crip (en-purl:html url))
      ?^  kid
        kid+s+u.kid
      ?>  ?=(^ key)
      jwk+~(pass jwk u.key) 
    ==
  %-  (corl as-octt:mimes:html en-json:html)
  ^-  json
  :-  %o  %-  my  :~
    protected+s+protect
    payload+s+payload
    :+  %signature  %s
    %-  en-base64url
    ?>  ?=(^ key)
    %-  ~(sign rs256 u.key)
    (rap 3 ~[protect '.' payload])
  == 
::  
++  request
  |=  [wir=wire url=purl bod=(unit json)]
  =/  lod
    ?~  bod
      [%get ~ ~]
    =/  hed  (my content-type+['application/jose+json' ~] ~)
    [%post hed `(jws-body url u.bod)]
  (emit [%hiss wir [~ ~] %httr %hiss url lod])
::
++  initialize
  =?  key  ?=(~ key)  `(new-key:rsa 2.048 eny.bow)
  (request /acme/init/(scot %p our.bow) bas ~)
::
++  nonce
  (request /acme/non/(scot %p our.bow) non.dir ~)
::
++  register
  %^  request  /acme/reg/(scot %p our.bow)
    reg.dir
  `[%o (my [['termsOfServiceAgreed' b+&] ~])]
::
++  authorize
  :+  request
    der.dir ::aut.dir
  ^-  json
  :-  %o  %-  my  :~
    resource+s+'new-authz'
    :-  %identifier
    :-  %o  %-  my  :~
      type+s+'dns'
      value+s+(crip (welp +:(scow %p our.bow) ".urbit.org"))
    ==
  ==
::
++  poke-noun
  |=  a=*
  ^-  (quip move _this)
  ?+  a  ~&  +<+.this
         [~ this]
    %init  abet:initialize
    %test  test
  ==
::
++  sigh-httr
  |=  [wir=wire rep=httr:eyre]
  ^-  (quip move _this)
  ~&  [wir rep]
  ?>  ?=([%acme ^] wir)
  ?.  ?=(%2 (div p.rep 100))
    ~&  %lack-of-success
    [~ +>]
  ?+  i.t.wir  !!
      %init
    =<  abet:nonce
    this(dir (from-json (need (de-json:html q:(need r.rep)))))
      ::
      %non
    =<  abet:register
    this(non q:(head (skim q.rep |=((pair @t @t) ?=(%replay-nonce p)))))
  ==
::
++  prep  _[~ this]
::
++  test
  =,  tester:tester
  =/  eny  eny.bow
    :: non-deterministic for now
    :: 0vhu.gp79o.hi7at.smp8u.g5hhr.u3rff.st8ms.q4dc2.hv5ls.tp5cp.10qds.
    ::      h9bpt.vlmm7.lh375.f6u9n.krqv8.5jcml.cujkr.v1uqv.cjhe5.nplta
  |^  =/  out=tang
          ;:  weld
            test-base64
            test-asn1
            testrsakey
            testrsa
            test-rsapem
            test-rs256
            testjwkthumbprint
            :: testjws
          ==
      ?~(out abet ((slog out) abet))
  ::
  ++  test-base64
    =/  jon  '{"iss":"joe","exp":1300819380,"http://example.com/is_root":true}'
    ;:  weld
      %-  expect-eq  !>
        :-  'AQAB'
        (en-base64url 65.537)
      %-  expect-eq  !>
        :-  65.537
        (need (de-base64url 'AQAB'))
      :: expected value includes newlines
      :: %-  expect-eq  !>
      ::   ~&  (en-base64:mimes:html jon)
      ::   :-  %+  weld
      ::         "eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQo"
      ::       "gImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ"
      ::   (en-base64url jon)
    ==
  ::
  ++  test-asn1
    =/  nul=spec:asn1  [%nul ~]
    =/  int=spec:asn1  [%int 187]
    =/  obj=spec:asn1  [%obj sha-256:obj:asn1]
    =/  oct=spec:asn1  [%oct (shax 'hello\0a')]
    =/  seq=spec:asn1  [%seq [%seq obj nul ~] oct ~]
    ;:  weld
      %-  expect-eq  !>
        :-  [0x5 0x0 ~]
        ~(ren asn1 nul)
      %-  expect-eq  !>
        [nul (scan ~(ren asn1 nul) decode:asn1)]
      %-  expect-eq  !>
        :-  [0x2 0x2 0x0 0xbb ~]
        ~(ren asn1 int)
      %-  expect-eq  !>
        [int (scan ~(ren asn1 int) decode:asn1)]
      %-  expect-eq  !>
        :-  [0x6 0x9 0x60 0x86 0x48 0x1 0x65 0x3 0x4 0x2 0x1 ~]
        ~(ren asn1 obj)
      %-  expect-eq  !>
        [obj (scan ~(ren asn1 obj) decode:asn1)]
      %-  expect-eq  !>
        :-    0x420.5891.b5b5.22d5.df08.6d0f.f0b1.10fb.
          d9d2.1bb4.fc71.63af.34d0.8286.a2e8.46f6.be03
        `@ux`(swp 3 (rep 3 ~(ren asn1 oct)))
      %-  expect-eq  !>
        [oct (scan ~(ren asn1 oct) decode:asn1)]
      %-  expect-eq  !>
        :-  0x30.3130.0d06.0960.8648.0165.0304.0201.0500.0420.5891.b5b5.22d5.
            df08.6d0f.f0b1.10fb.d9d2.1bb4.fc71.63af.34d0.8286.a2e8.46f6.be03
        `@ux`(swp 3 (rep 3 ~(ren asn1 seq)))
      %-  expect-eq  !>
        [seq (scan ~(ren asn1 seq) decode:asn1)]
    ==
  ::
  ++  testrsakey
    =/  primes=(list @)
      :~    2    3    5    7   11   13   17   19   23   29   31   37   41   43
           47   53   59   61   67   71   73   79   83   89   97  101  103  107
          109  113  127  131  137  139  149  151  157  163  167  173  179  181
          191  193  197  199  211  223  227  229  233  239  241  251  257  263
          269  271  277  281  283  293  307  311  313  317  331  337  347  349
          353  359  367  373  379  383  389  397  401  409  419  421  431  433
          439  443  449  457  461  463  467  479  487  491  499  503  509  521
          523  541  547  557  563  569  571  577  587  593  599  601  607  613
          617  619  631  641  643  647  653  659  661  673  677  683  691  701
          709  719  727  733  739  743  751
      ==
    =/  k1  (new-key:rsa 2.048 eny)
    ::
    =/  k2=key:rsa
      =/  p  0x1837.be57.1286.bf6a.3cf8.4716.634f.ef85.f947.c654.da6e.e222.
          5654.9466.0ab0.a2ef.1985.1095.e3c3.9e74.9478.e3f3.ee92.f885.ec3c.
          84c3.6b3c.9731.65f9.9d1d.f743.646f.37d7.82d8.3f4a.856c.6453.b2c8.
          28d5.d720.145e.c7ab.4ba9.a9c2.6b8e.8819.7aa8.69b3.420f.dbfa.1ddb.
          4d1a.9c2e.e25a.d4de.d351.945f.d7ca.74a4.815d.5f0e.9f44.df64.39bd
      =/  q  0xf1bc.ec8f.d238.32d9.afb8.8083.76b3.82da.6274.f56e.1b5b.662b.
          ab1b.1e01.fbd5.86c5.ba98.b246.b621.f190.2425.25ea.b39f.efa2.4fb8.
          0d6b.c3c4.460d.e7df.d2f5.6604.51e0.415b.db60.db5a.6601.16c7.46ec.
          5e67.9195.f3c9.80d3.47c5.fe24.fbfd.43c3.380a.40bd.c4f5.d65e.b93b.
          60ca.5f26.4ed7.9c64.d26d.b0fe.985d.7be3.1308.34dd.b8c5.4d7c.d8a5
      =/  n  (mul p q)
      =/  e  0x1.0001
      =/  d  (~(inv fo (elcm:rsa (dec p) (dec q))) e)
      [p q n e d]
    ::
    |^  ^-  tang
        ;:  weld
            (check-primes k1)
            (check-primes k2)
        ==
    ++  check-primes
      =,  number
      |=  k=key:rsa
      %+  roll  primes
      |=  [p=@ a=tang]
      ?^  a  a
      ?:  =(0 (mod n.k p))
        :~  leaf+"{(scow %ux n.k)}"
            :-  %leaf
            %+  weld
              "n.key (prime? {(scow %f (pram n.k))})"
            " divisible by {(scow %ud p)}:"
        ==
      ?:  =(0 (mod p.k p))
        :~  leaf+"{(scow %ux p.k)}"
            :-  %leaf
            %+  weld
              "p.key (prime? {(scow %f (pram p.k))})"
            " divisible by {(scow %ud p)}:"
        ==
      ?:  =(0 (mod q.k p))
        :~  leaf+"{(scow %ux q.k)}"
            :-  %leaf
            %+  weld
              "q.key (prime? {(scow %f (pram q.k))})"
            " divisible by {(scow %ud p)}:"
        ==
      ~
    --
  ::
  ++  test-rsapem
    =/  k1=key:rsa  [`@ux`17 `@ux`11 `@ux`187 `@ux`7 `@ux`23]
    =/  kpem1=wain
      :~  '-----BEGIN RSA PRIVATE KEY-----'
          'MBwCAQACAgC7AgEHAgEXAgERAgELAgEHAgEDAgEO'
          '-----END RSA PRIVATE KEY-----'
      ==
    =/  k2=key:rsa
      :*  p=`@ux`4.140.273.707
          q=`@ux`3.922.198.019
          n=`@ux`16.238.973.331.713.186.433
          e=`@ux`65.537
          d=`@ux`3.298.243.342.098.580.397
      ==
    =/  kpem2=wain
      :~  '-----BEGIN RSA PRIVATE KEY-----'
          'MEACAQACCQDhXGw1Gc5agQIDAQABAggtxbbYRJVDrQIFAPbHkCsCBQDpx/4DAgUA'
          '23X55QIFAIpPROsCBQC56nYF'
          '-----END RSA PRIVATE KEY-----'
      ==
    =/  kpem3=wain
      :~  '-----BEGIN RSA PRIVATE KEY-----'
          'MIIEowIBAAKCAQEA2jJp8dgAKy5cSzDE4D+aUbKZsQoMhIWI2IFlE+AO0GCBMig5'
          'qxx2IIAPVIcSi5fjOLtTHnuIZYw+s06qeb8QIKRvkZaIwnA3Lz5UUrxgh96sezdX'
          'CCSG7FndIFskcT+zG00JL+fPRdlPjt1Vg2b3kneo5aAKMIPyOTzcY590UTc+luQ3'
          'HhgSiNF3n5YQh24d3kS2YOUoSXQ13+YRljxNfBgXbV+C7/gO8mFxpkafhmgkIGNe'
          'WlqT9oAIRa+gOx13uPAg+Jb/8lPV9bGaFqGvxvBMp3xUASlzYHiDntcB5MiOPRW6'
          'BoIGI5qDFSYRZBky9crE7WAYgqtPtg21zvxwFwIDAQABAoIBAH0q7GGisj4TIziy'
          '6k1lzwXMuaO4iwO+gokIeU5UessIgTSfpK1G73CnZaPstDPF1r/lncHfxZfTQuij'
          'WOHsO7kt+x5+R0ebDd0ZGVA45fsrPrCUR2XRZmDRECuOfTJGA13G7F1B0kJUbfIb'
          'gAGYIK8x236WNyIrntk804SGpTgstCsZ51rK5GL6diZVQbeU806oP1Zhx/ye//NR'
          'mS5G0iil//H41pV5WGomOX0mq9/HYBZqCncqzLki6FFdmXykjz8snvXUR40S8B+a'
          '0F/LN+549PSe2dp9h0Hx4HCJOsL9CyCQimqqqE8KPQ4BUz8q3+Mhx1xEyaxIlNH9'
          'ECgo1CECgYEA+mi7vQRzstYJerbhCtaeFrOR/n8Dft7FyFN+5IV7H2omy6gf0zr1'
          'GWjmph5R0sMPgL8uVRGANUrkuZZuCr35iY6zQpdCFB4D9t+zbTvTmrxt2oVaE16/'
          'dIJ6b8cHzR2QrEh8uw5/rEKzWBCHNS8FvXHPvXvnacTZ5LZRK0ssshECgYEA3xGQ'
          'nDlmRwyVto/1DQMLnjIMazQ719qtCO/pf4BHeqcDYnIwYb5zLBj2nPV8D9pqM1pG'
          'OVuOgcC9IimrbHeeGwp1iSTH4AvxDIj6Iyrmbz2db3lGdHVk9xLvTiYzn2KK2sYx'
          'mFl3DRBFutFQ2YxddqHbE3Ds96Y/uRXhqj7I16cCgYEA1AVNwHM+i1OS3yZtUUH6'
          'xPnySWu9x/RTvpSDwnYKk8TLaHDH0Y//6y3Y7RqK6Utjmv1E+54/0d/B3imyrsG/'
          'wWrj+SQdPO9VJ/is8XZQapnU4cs7Q19b+AhqJq58un2n+1e81J0oGPC47X3BHZTc'
          '5VSyMpvwiqu0WmTMQT37cCECgYACMEbt8XY6bjotz13FIemERNNwXdPUe1XFR61P'
          'ze9lmavj1GD7JIY2wYvx4Eq2URtHo7QarfZI+Z4hbq065DWN6F1c2hqH7TYRPGrP'
          '24TlRIJ97H+vdtNlxS7J4oARKUNZgCZOa1pKq4UznwgfCkyEdHQUzb/VcjEf3MIZ'
          'DIKl8wKBgBrsIjiDvpkfnpmQ7fehEJIi+V4SGskLxFH3ZTvngFFoYry3dL5gQ6mF'
          'sDfrn4igIcEy6bMpJQ3lbwStyzcWZLMJgdI23FTlPXTEG7PclZSuxBpQpvg3MiVO'
          'zqVTrhnY+TemcScSx5O6f32aDfOUWWCzmw/gzvJxUYlJqjqd7dlT'
          '-----END RSA PRIVATE KEY-----'
      ==
    =/  kder3=@ux
      (need (de:base64 (rap 3 (swag [1 (sub (lent kpem3) 2)] kpem3))))
    =/  k3=key:rsa
      (need (ring:de:pem:rsa kpem3))
    ;:  weld
      %-  expect-eq  !>
        [kpem1 (ring:en:pem:rsa k1)]
      %-  expect-eq  !>
        [k1 (need (ring:de:pem:rsa kpem1))]
      %-  expect-eq  !>
        [kpem2 (ring:en:pem:rsa k2)]
      %-  expect-eq  !>
        [k2 (need (ring:de:pem:rsa kpem2))]
      %-  expect-eq  !>
        [kpem3 (ring:en:pem:rsa k3)]
      %-  expect-eq  !>
        [kder3 (ring:en:der:rsa k3)]
    ==
  ::
  ++  testrsa
    =/  k1=key:rsa
      =/  p  `@ux`61
      =/  q  `@ux`53
      =/  e  `@ux`17
      =/  n  (mul p q)
      =/  d  (~(inv fo (elcm:rsa (dec p) (dec q))) e)
      [p q n e d]
    ::
    =/  k2=key:rsa  [`@ux`11 `@ux`13 `@ux`143 `@ux`7 `@ux`103]
    ::
    =/  k3=key:rsa
      =/  p
    12.131.072.439.211.271.897.323.671.531.612.440.428.472.427.633.701.410.
       925.634.549.312.301.964.373.042.085.619.324.197.365.322.416.866.541.
       017.057.361.365.214.171.711.713.797.974.299.334.871.062.829.803.541
      =/  q
    12.027.524.255.478.748.885.956.220.793.734.512.128.733.387.803.682.075.
       433.653.899.983.955.179.850.988.797.899.869.146.900.809.131.611.153.
       346.817.050.832.096.022.160.146.366.346.391.812.470.987.105.415.233
      =/  n  (mul p q)
      =/  e  65.537
      =/  d  (~(inv fo (elcm:rsa (dec p) (dec q))) e)
      [`@ux`p `@ux`q `@ux`n `@ux`e `@ux`d]
    =/  m3  (swp 3 'attack at dawn')
    =/  c3
      35.052.111.338.673.026.690.212.423.937.053.328.511.880.760.811.579.981.
         620.642.802.346.685.810.623.109.850.235.943.049.080.973.386.241.113.
         784.040.794.704.193.978.215.378.499.765.413.083.646.438.784.740.952.
         306.932.534.945.195.080.183.861.574.225.226.218.879.827.232.453.912.
         820.596.886.440.377.536.082.465.681.750.074.417.459.151.485.407.445.
         862.511.023.472.235.560.823.053.497.791.518.928.820.272.257.787.786
    ::
    ;:  weld
      %-  expect-eq  !>
        [413 d.k1]
      %-  expect-eq  !>
        [2.790 (en:rsa 65 k1)]
      %-  expect-eq  !>
        [65 (de:rsa 2.790 k1)]
      ::
      %-  expect-eq  !>
        [48 (en:rsa 9 k2)]
      %-  expect-eq  !>
        [9 (de:rsa 48 k2)]
      ::
      %-  expect-eq  !>
        [c3 (en:rsa m3 k3)]
      %-  expect-eq  !>
        [m3 (de:rsa c3 k3)]
    ==
  ::
  ++  test-rs256
    =/  k1=key:rsa
      :*  0xf7ef.37e6.7fa6.685a.c178.8b01.cf38.da20.ca4b.de5d.8b01.a71b.d28c.
            65b4.09c3.6e4d
          0xc882.5760.3fb8.a5e2.5e9d.db55.3a73.b647.a3ec.a6e9.abc6.c440.dbc7.
            05f8.2ed4.da6b
          0xc231.1fc5.fa31.d333.a409.bb4c.e95b.20d2.1cfc.e375.3871.7256.53a2.
            8425.af6d.e97d.f202.0b23.633f.458d.f12a.6362.7121.bff4.e23c.e578.
            7e07.7898.0578.61d1.ae60.ac2f
          0x1.0001
           0xd91.6719.eb10.3e24.768a.a386.8d2b.6bd0.a26b.dcec.9cc3.f86c.25ad.
            ce33.dfdc.fb1a.4d50.3e07.3d7f.f5fd.748e.43f8.df02.a60e.d730.5314.
            3e59.1e70.8df7.2c27.93e2.2b69
      ==
    =/  inp1  0x302.0101
    =/  exp1
      0x575c.8a41.09ed.6ea2.a708.6338.d150.a5bb.8205.142e.7785.47b5.0cc6.0198.
        6807.0243.bf49.de7c.6039.0160.e392.faca.18f4.a05d.3a7a.88a4.de86.dd99.
        f030.eb4a.a755.d7ce
    =/  kpem2=wain
      :~  '-----BEGIN RSA PRIVATE KEY-----'
          'MIIEowIBAAKCAQEA2jJp8dgAKy5cSzDE4D+aUbKZsQoMhIWI2IFlE+AO0GCBMig5'
          'qxx2IIAPVIcSi5fjOLtTHnuIZYw+s06qeb8QIKRvkZaIwnA3Lz5UUrxgh96sezdX'
          'CCSG7FndIFskcT+zG00JL+fPRdlPjt1Vg2b3kneo5aAKMIPyOTzcY590UTc+luQ3'
          'HhgSiNF3n5YQh24d3kS2YOUoSXQ13+YRljxNfBgXbV+C7/gO8mFxpkafhmgkIGNe'
          'WlqT9oAIRa+gOx13uPAg+Jb/8lPV9bGaFqGvxvBMp3xUASlzYHiDntcB5MiOPRW6'
          'BoIGI5qDFSYRZBky9crE7WAYgqtPtg21zvxwFwIDAQABAoIBAH0q7GGisj4TIziy'
          '6k1lzwXMuaO4iwO+gokIeU5UessIgTSfpK1G73CnZaPstDPF1r/lncHfxZfTQuij'
          'WOHsO7kt+x5+R0ebDd0ZGVA45fsrPrCUR2XRZmDRECuOfTJGA13G7F1B0kJUbfIb'
          'gAGYIK8x236WNyIrntk804SGpTgstCsZ51rK5GL6diZVQbeU806oP1Zhx/ye//NR'
          'mS5G0iil//H41pV5WGomOX0mq9/HYBZqCncqzLki6FFdmXykjz8snvXUR40S8B+a'
          '0F/LN+549PSe2dp9h0Hx4HCJOsL9CyCQimqqqE8KPQ4BUz8q3+Mhx1xEyaxIlNH9'
          'ECgo1CECgYEA+mi7vQRzstYJerbhCtaeFrOR/n8Dft7FyFN+5IV7H2omy6gf0zr1'
          'GWjmph5R0sMPgL8uVRGANUrkuZZuCr35iY6zQpdCFB4D9t+zbTvTmrxt2oVaE16/'
          'dIJ6b8cHzR2QrEh8uw5/rEKzWBCHNS8FvXHPvXvnacTZ5LZRK0ssshECgYEA3xGQ'
          'nDlmRwyVto/1DQMLnjIMazQ719qtCO/pf4BHeqcDYnIwYb5zLBj2nPV8D9pqM1pG'
          'OVuOgcC9IimrbHeeGwp1iSTH4AvxDIj6Iyrmbz2db3lGdHVk9xLvTiYzn2KK2sYx'
          'mFl3DRBFutFQ2YxddqHbE3Ds96Y/uRXhqj7I16cCgYEA1AVNwHM+i1OS3yZtUUH6'
          'xPnySWu9x/RTvpSDwnYKk8TLaHDH0Y//6y3Y7RqK6Utjmv1E+54/0d/B3imyrsG/'
          'wWrj+SQdPO9VJ/is8XZQapnU4cs7Q19b+AhqJq58un2n+1e81J0oGPC47X3BHZTc'
          '5VSyMpvwiqu0WmTMQT37cCECgYACMEbt8XY6bjotz13FIemERNNwXdPUe1XFR61P'
          'ze9lmavj1GD7JIY2wYvx4Eq2URtHo7QarfZI+Z4hbq065DWN6F1c2hqH7TYRPGrP'
          '24TlRIJ97H+vdtNlxS7J4oARKUNZgCZOa1pKq4UznwgfCkyEdHQUzb/VcjEf3MIZ'
          'DIKl8wKBgBrsIjiDvpkfnpmQ7fehEJIi+V4SGskLxFH3ZTvngFFoYry3dL5gQ6mF'
          'sDfrn4igIcEy6bMpJQ3lbwStyzcWZLMJgdI23FTlPXTEG7PclZSuxBpQpvg3MiVO'
          'zqVTrhnY+TemcScSx5O6f32aDfOUWWCzmw/gzvJxUYlJqjqd7dlT'
          '-----END RSA PRIVATE KEY-----'
      ==
    =/  k2=key:rsa
      (need (ring:de:pem:rsa kpem2))
    =/  inp2=cord  'hello\0a'
    =/  exp2=@ux
      0x2920.bba3.cb38.bca6.3768.6345.c95e.0717.81bf.6c61.4006.6070.a7b5.e609.
        f3b4.7f48.878b.d1f8.1882.8852.1db6.b6b5.a5fd.c23b.e764.b910.5a3f.fda9.
        9d3a.e8bd.060a.ac06.58f1.487a.b50d.dee2.e161.0b74.4d3b.e6e3.7004.c721.
        4f32.5c95.ce68.a008.b1e9.788b.375f.d389.0fa4.4012.c07a.8319.a183.02d5.
        e2b8.10df.6ff7.f64a.6b85.3c7d.de80.19cf.ab6d.e588.40cb.0ea4.c436.8d8b.
        47f7.cce6.b9bf.097d.3275.c128.147a.628d.2b7c.3912.3950.ef68.87b2.180d.
        ba01.3b05.285d.3dfd.09ee.2f38.3111.9e4c.92c6.bf66.a91b.5762.3cdf.f8b7.
        8281.81a2.8324.5330.43c1.035a.56c3.71b8.eb85.e660.c3a4.28b4.8af7.c16f.
        7d7d.87cc.036d.aeb2.c757.30f5.f194.c90d.6bb4.5e5c.f95f.8e28.0fbc.5fb4.
        b21a.e6fe
    =/  exp2b64=cord
      %+  rap  3
      :~  'KSC7o8s4vKY3aGNFyV4HF4G/bGFABmBwp7XmCfO0f0iHi9H4GIKIUh22trWl/cI752S5'
          'EFo//amdOui9BgqsBljxSHq1Dd7i4WELdE075uNwBMchTzJclc5ooAix6XiLN1/TiQ+k'
          'QBLAeoMZoYMC1eK4EN9v9/ZKa4U8fd6AGc+rbeWIQMsOpMQ2jYtH98zmub8JfTJ1wSgU'
          'emKNK3w5EjlQ72iHshgNugE7BShdPf0J7i84MRGeTJLGv2apG1diPN/4t4KBgaKDJFMw'
          'Q8EDWlbDcbjrheZgw6QotIr3wW99fYfMA22ussdXMPXxlMkNa7ReXPlfjigPvF+0shrm'
          '/g=='
      ==
    =/  sig=@ux  (~(sign rs256 k2) inp2)
    ;:  weld
      %-  expect-eq  !>
        [exp1 (~(sign rs256 k1) inp1)]
      %-  expect-eq  !>
        [& (~(verify rs256 k1) exp1 inp1)]
      %-  expect-eq  !>
        [& (~(verify rs256 k2) sig inp2)] 
      %-  expect-eq  !>
        [exp2 sig]
      :: save kpem2 to private.pem
      :: echo "hello" | openssl dgst -sha256 -sign private.pem | base64
      %-  expect-eq  !>
        [exp2b64 (en:base64 (swp 3 sig))]
    ==
  ::
  ++  testjwkthumbprint
    =/  n
      :~  '0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2'
          'aiAFbWhM78LhWx4cbbfAAtVT86zwu1RK7aPFFxuhDR1L6tSoc_BJECPebWKRXjBZCi'
          'FV4n3oknjhMstn64tZ_2W-5JsGY4Hc5n9yBXArwl93lqt7_RN5w6Cf0h4QyQ5v-65Y'
          'GjQR0_FDW2QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0zgdAZHzu6qMQvRL5hajrn1n'
          '91CbOpbISD08qNLyrdkt-bFTWhAI4vMQFh6WeZu0fM4lFd2NcRwr3XPksINHaQ-G_x'
          'BniIqbw0Ls1jF44-csFCur-kEgU8awapJzKnqDKgw'
      ==
    =/  k=json
      :-  %o  %-  my  :~
        e+s+'AQAB'
        kty+s+'RSA'
        n+s+(rap 3 n)
      ==
    ::
    %-  expect-eq  !>
      :-  'NzbLsXh8uDCcd-6MNwXF4W_7noWXFZAfHkxZsRGC9Xs'
      (thumbprint k)
  ::
  ++  testjws
    ^-  wall
    =/  pt=@t
      %+  rap  3
      :~  '4BzEEOtIpmVdVEZNCqS7baC4crd0pqnRH_5IB3jw3bcxGn6QLvnEtfdUdi'
          'YrqBdss1l58BQ3KhooKeQTa9AB0Hw_Py5PJdTJNPY8cQn7ouZ2KKDcmnPG'
          'BY5t7yLc1QlQ5xHdwW1VhvKn-nXqhJTBgIPgtldC-KDV5z-y2XDwGUc'
      ==
    =/  qt=@t
      %+  rap  3
      :~  'uQPEfgmVtjL0Uyyx88GZFF1fOunH3-7cepKmtH4pxhtCoHqpWmT8YAmZxa'
          'ewHgHAjLYsp1ZSe7zFYHj7C6ul7TjeLQeZD_YwD66t62wDmpe_HlB-TnBA'
          '-njbglfIsRLtXlnDzQkv5dTltRJ11BKBBypeeF6689rjcJIDEz9RWdc'
      ==
    =/  nt=@t
      %+  rap  3
      :~  'ofgWCuLjybRlzo0tZWJjNiuSfb4p4fAkd_wWJcyQoTbji9k0l8W26mPddx'
          'HmfHQp-Vaw-4qPCJrcS2mJPMEzP1Pt0Bm4d4QlL-yRT-SFd2lZS-pCgNMs'
          'D1W_YpRPEwOWvG6b32690r2jZ47soMZo9wGzjb_7OMg0LOL-bSf63kpaSH'
          'SXndS5z5rexMdbBYUsLA9e-KXBdQOS-UTo7WTBEMa2R2CapHg665xsmtdV'
          'MTBQY4uDZlxvb3qCo5ZwKh9kG4LT6_I5IhlJH7aGhyxXFvUK-DWNmoudF8'
          'NAco9_h9iaGNj8q2ethFkMLs91kzk2PAcDTW9gb54h4FRWyuXpoQ'
       ==
    =/  dt=@t
      %+  rap  3
      :~  'Eq5xpGnNCivDflJsRQBXHx1hdR1k6Ulwe2JZD50LpXyWPEAeP88vLNO97I'
          'jlA7_GQ5sLKMgvfTeXZx9SE-7YwVol2NXOoAJe46sui395IW_GO-pWJ1O0'
          'BkTGoVEn2bKVRUCgu-GjBVaYLU6f3l9kJfFNS3E0QbVdxzubSu3Mkqzjkn'
          '439X0M_V51gfpRLI9JYanrC4D4qAdGcopV_0ZHHzQlBjudU2QvXt4ehNYT'
          'CBr6XCLQUShb1juUO1ZdiYoFaFQT5Tw8bGUl_x_jTj3ccPDVZFD9pIuhLh'
          'BOneufuBiB4cS98l2SR_RQyGWSeWjnczT0QU91p1DhOVRuOopznQ'
      ==
    =/  p  :: (de-base64url pt)
           0x4719.f070.d9b2.3fe7.d5a0.f842.57b6.e083.80c1.9484.ea75.faa7.
        f286.556d.c1dd.11e7.5009.d5dc.22ef.6d8e.05c6.739a.dca0.2876.e6a2.
        fb09.713c.f634.c9d4.254f.2e3f.3f7c.d001.d06b.13e4.2928.1a2a.3714.
        f079.59b3.6c17.a82b.2676.54f7.b5c4.f92e.907e.1a31.b7dd.f078.0748.
        fe1f.d1a9.a674.b772.b8a0.6dbb.a40a.4d46.545d.65a6.48eb.10c4.1ce0
    =/  q  :: (de-base64url qt)
           0xd759.513f.1303.9270.e3da.f3ba.5e78.5e2a.0781.12d4.7512.b5e5.
        d4e5.2f09.cdc3.595e.ed12.b1c8.5782.db78.fa40.704e.7e50.1ebf.979a.
        036c.ebad.ae0f.30f6.0f99.072d.de38.eda5.ab0b.fb78.60c5.bc7b.5256.
        a72c.b68c.c001.1eb0.a7c5.9909.60fc.645a.a97a.a042.1bc6.297e.b4a6.
        927a.dcee.dfc7.e93a.5f5d.1499.c1f3.b12c.53f4.32b6.9509.7ec4.03b9
    =/  n  :: (de-base64url nt)
           :: (mul p q)
                0xa1e9.e5ca.5654.e021.9e6f.606f.4d03.073c.3639.9375.cf2e.
        0c59.84ad.67ab.fcd8.189a.d887.7f8f.7240.c317.9d8b.9a8d.35f8.0af5.
        1657.2c87.86b6.1f49.1922.39f2.ebd3.821b.641f.2a70.96a3.827a.6f6f.
        5c66.838b.6350.3031.55d7.9a6c.9ceb.3a78.a49a.6047.b6c6.10c1.64ed.
        e844.f992.0375.c1a5.f85e.0f2c.2c85.055b.c7c4.de9a.cfb9.d49d.9774.
        485a.4ade.fa27.6dfe.e22c.34c8.38fb.bf8d.b301.f768.c6a0.ec8e.67a3.
        bdd2.bd6e.df9b.6ebc.9603.134f.9462.bf55.0f2c.d380.42ea.4b59.6977.
        85e4.4f91.ec2f.2584.77b8.19d0.ed53.3f33.c13c.8969.4bdc.9a08.8f8a.
        fbb0.56f9.2974.7ce6.1177.dd63.eab6.c597.34d9.8be3.36a1.90cc.2516.
        fc77.24f0.e129.be7d.922b.3663.6265.2d8d.ce65.b4c9.e3e2.0a16.f8a1
    =/  d  :: (de-base64url dt)
                0x9d73.8a3a.6e54.39e1.50a7.754f.41f4.3473.e768.7992.65c8.
        50f4.4792.5df2.bdc4.e181.18b8.9feb.9d4e.102e.a18b.a4fd.5064.d5f0.
        70dc.3d4e.e31f.ff25.656c.3c3c.e513.5468.058a.895d.563b.943b.d65b.
        2851.d022.5cfa.1a08.13d6.841e.de5e.2f64.539d.3b06.2534.1f47.46ff.
        558a.7246.07a8.f880.0beb.a961.498f.2c51.fa81.755e.fd0c.7df5.377e.
        92e3.ac92.cced.4a9b.3bc7.5db5.4134.714b.4df1.2564.5fde.9f4e.2d98.
        5605.a3e1.bba0.4045.95b2.d927.51a1.c644.06b4.5327.56ea.3bc6.6f21.
        797f.8b2e.abe3.5e02.a0ce.d5d8.255a.c1d8.ee13.521f.6797.377d.2fc8.
        280b.9b43.c6bf.03e5.88ec.bdd3.2c2f.cf3f.1e40.3c96.7ca5.0b9d.0f59.
        627b.7049.e964.1d75.611d.1f57.0045.6c52.7ec3.2b0a.cd69.a471.ae12
    =/  e  `@ux`65.537
    =/  k=key:rsa  [p q n e d]
    =/  hed=json  o+(my alg+s+'RS256' ~)
    =/  lod=json
      :-  %o  %-  my  :~
        iss+s+'joe'
        exp+n+'1300819380'
        ['http://example.com/is_root' %b &]
      ==
    =/  lod-order
      =/  keys=(list @t)  ['iss' 'exp' 'http://example.com/is_root' ~]
      |=  [a=* b=*]
      =/  fa  (find ~[a] keys)
      =/  fb  (find ~[b] keys)
      ?~  fa  |
      ?~  fb  |
      (lte u.fa u.fb)
    =/  inp=@t
      :: %+  swp  3
      %-  crip
      ;:  weld
        "eyJhbGciOiJSUzI1NiJ9"
        "."
        "eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQo"
        "gImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ"
      ==
    =/  exp=@t
      %+  rap  3
      :~  'cC4hiUPoj9Eetdgtv3hF80EGrhuB__dzERat0XF9g2VtQgr9PJbu3XOiZj5RZmh7'
          'AAuHIm4Bh-0Qc_lF5YKt_O8W2Fp5jujGbds9uJdbF9CUAr7t1dnZcAcQjbKBYNX4'
          'BAynRFdiuB--f_nZLgrnbyTyWzO75vRK5h6xBArLIARNPvkSjtQBMHlb1L07Qe7K'
          '0GarZRmB_eSN9383LcOLn6_dO--xi12jzDwusC-eOkHWEsqtFZESc6BfI7noOPqv'
          'hJ1phCnvWh6IeYI2w9QOYEUipUTI8np6LbgGY9Fs98rqVt5AXLIhWkWywlVmtVrB'
          'p0igcN_IoypGlUPQGe77Rw'
      ==
    ;:  weld
      %-  expect-eq  !>
        :-  'eyJhbGciOiJSUzI1NiJ9'
        (en-base64url (crip (en-json-sort aor hed)))
      %-  expect-eq  !>
        [pt p=(en-base64url p)]
      %-  expect-eq  !>
        [p p=(de-base64url pt)]
      %-  expect-eq  !>
        [qt q=(en-base64url q)]
      %-  expect-eq  !>
        [nt n=(en-base64url n)]
      %-  expect-eq  !>
        [dt d=(en-base64url d)]
      %-  expect-eq  !>
        [`@ux`n check-math=`n=@ux`(mul p q)]
      %-  expect-eq  !>
        [`@ux`d check-math=`d=@ux`(~(inv fo (elcm:rsa (dec p) (dec q))) e)]
      %-  expect-eq  !>
        :-  exp
        =/  sig  (~(sign rs256 k) inp)
        :: ~&  inp+(rip 3 (swp 3 inp))
        :: ~&  :*  [pt (de-base64url pt) (en-base64url (de-base64url pt))]
        ::         [qt (de-base64url qt) (en-base64url (de-base64url qt))]
        ::         [nt (de-base64url nt) (en-base64url (de-base64url nt))]
        ::         [dt (de-base64url dt) (en-base64url (de-base64url dt))]
        ::     ==
        :: ~&  ~(pass jwk k)
        `@ux`sig
        :: (en-base64url sig)
      :: expected value has newlines
      :: %-  expect-eq  !>
      ::   :-  %+  weld
      ::         "eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQo"
      ::       "gImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ"
      ::   (en-base64url (crip (en-json-sort lod-order lod)))
    ==
    --
--

