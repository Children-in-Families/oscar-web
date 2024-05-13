import en from "../../utils/locales/en.json";
import km from "../../utils/locales/km.json";
import my from "../../utils/locales/my.json";
import id from "../../utils/locales/id.json";

import T from "i18n-react";

export const setDefaultLanguage = (url) => {
  switch (url) {
    case "km":
      T.setTexts(km);
      break;
    case "my":
      T.setTexts(my);
      break;
    case "id":
      T.setTexts(id);
      break;
    default:
      T.setTexts(en);
      break;
  }

  return T;
};
