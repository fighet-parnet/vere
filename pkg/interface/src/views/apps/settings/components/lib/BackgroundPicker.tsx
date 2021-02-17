import React from "react";
import {
  Box,
  Text,
  Row,
  Label,
  Col,
  ManagedRadioButtonField as Radio,
  ManagedTextInputField as Input,
} from "@tlon/indigo-react";

import GlobalApi from "~/logic/api/global";
import { S3State } from "~/types";
import { ImageInput } from "~/views/components/ImageInput";
import {ColorInput} from "~/views/components/ColorInput";

export type BgType = "none" | "url" | "color";

export function BackgroundPicker({
  bgType,
  bgUrl,
  api,
  s3,
}: {
  bgType: BgType;
  bgUrl?: string;
  api: GlobalApi;
  s3: S3State;
}) {

  const rowSpace = { my: 0, alignItems: 'center' };
  const colProps = { my: 3, mr: 4, gapY: 1 };
  return (
    <Col>
      <Label>Landscape Background</Label>
      <Row flexWrap="wrap" {...rowSpace}>
        <Col {...colProps}>
          <Radio mb="1" name="bgType" label="Image" id="url" />
          <Text ml="5" gray>Set an image background</Text>
          <ImageInput
            ml="5"
            api={api}
            s3={s3}
            id="bgUrl"
            placeholder="Drop or upload a file, or paste a link here"
            name="bgUrl"
            url={bgUrl || ""}
          />
        </Col>
      </Row>
      <Row {...rowSpace}>
        <Col {...colProps}>
          <Radio mb="1" label="Color" id="color" name="bgType" />
          <Text ml="5" gray>Set a hex-based background</Text>
          <ColorInput placeholder="FFFFFF" ml="5" id="bgColor" /> 
        </Col>
      </Row>
      <Radio
        my="3"
        caption="Your home screen will simply render as its respective day/night mode color"
        name="bgType" 
        label="None"
        id="none" />
    </Col>
  );
}
