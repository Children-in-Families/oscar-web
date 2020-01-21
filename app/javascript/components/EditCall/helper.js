
import en from '../../utils/locales/en.json';
import km from '../../utils/locales/km.json';
import my from '../../utils/locales/my.json';
import T from 'i18n-react'


export const setDefaultLanguage = (url) => {
  switch (url) {
    case "km":
      T.setTexts(km)
      break;
    case "my":
      T.setTexts(my)
      break;
    default:
      T.setTexts(en)
      break;
  }
  
  return T
}