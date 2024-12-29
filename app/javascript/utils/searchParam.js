export function urlSearchParam(paramText) {
  const queryString = window.location.search;
  const urlParams = new URLSearchParams(queryString);

  return urlParams.get(paramText);
}
