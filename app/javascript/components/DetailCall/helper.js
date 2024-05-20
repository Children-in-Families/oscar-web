import en from "../../utils/locales/en.json";
import km from "../../utils/locales/km.json";
import my from "../../utils/locales/my.json";
import id from "../../utils/locales/id.json";
import T from "i18n-react";

export const reject = (obj = {}, condition = "id|created_at|updated_at") => {
  var newObj = {};
  let keys = Object.keys(obj || {}) || [];

  keys.forEach((v) => {
    var pattern = new RegExp(condition, "gi");
    if (pattern.exec(v) == null && typeof pattern.exec(v) != Array) {
      newObj[v] = obj[v];
    }
  });

  return newObj || {};
};

export const titleize = (str = "") => {
  return str.replace(/\_/g, " ").replace(/(^|\s)\S/g, function (t) {
    return t.toUpperCase();
  });
};

export const formatDate = (dateStr) => {
  return new Date(dateStr).toLocaleString("en-NZ", {
    year: "numeric",
    month: "long",
    day: "numeric"
  });
};

export const isEmpty = (array = []) => {
  let newArr = array.filter(function (element) {
    if (element != "") return element;
  });

  return newArr.length <= 0;
};

export const formatTime = (dateStr) => {
  let d = new Date(dateStr);
  let time_format_str =
    d.getUTCHours() +
    ":" +
    (d.getUTCMinutes().toString().length == 1
      ? "0" + d.getUTCMinutes().toString()
      : d.getUTCMinutes());
  return time_format_str;
};

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
