export function t(data, key) {
  var keys = key.split('.')
  var value = data;

  for(var i=0; i < keys.length; i++ ) {
    value = value[keys[i]]
  }

  return value;
}