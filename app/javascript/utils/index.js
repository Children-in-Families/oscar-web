import Translate from "i18n-react";
import { t as TranslateUtil } from "./i18n";
import { urlSearchParam } from "./searchParam";

import en from "./locales/en.json";
import km from "./locales/km.json";
import my from "./locales/my.json";
import th from "./locales/th.json";
import id from "./locales/id.json";

var url = window.location.href.split("&").slice(-1)[0].split("=")[1];
switch (url) {
  case "km":
    Translate.setTexts(km);
    break;
  case "my":
    Translate.setTexts(my);
    break;
  case "th":
    Translate.setTexts(th);
    break;
  case "id":
    Translate.setTexts(id);
    break;
  default:
    Translate.setTexts(en);
    break;
}

export const T = Translate;
export const t = TranslateUtil;
export const params = urlSearchParam;
