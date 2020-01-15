export const reject = (obj, condition="id|created_at|updated_at") => {
  var newObj = {}
  
  Object.keys(obj).forEach((v) => {
    var pattern = new RegExp(condition, 'gi')
    if(pattern.exec(v) == null && typeof pattern.exec(v) != Array) {
      newObj[v] = obj[v]
    }
  })

  return newObj
}

export const titleize = (str = "") => {
  return str.replace(/\_/g, ' ').replace(/(^|\s)\S/g, function(t) { return t.toUpperCase() })
}

export const formatDate = (dateStr) => {
  return new Date(dateStr).toLocaleString('en-NZ',{year:'numeric', month:'long', day:'numeric'})
}

export const isEmpty = (array=[]) => {
  let newArr = array.filter(function(element) {
	  if(element != '') return element
  });

  return newArr.length <= 0
}

export const formatTime = (dateStr) => {
  let d = new Date();
  d = new Date(d.getTime() - 3000000);
  let time_format_str = (d.getHours().toString().length==2?d.getHours().toString():"0"+d.getHours().toString())+":"+((parseInt(d.getMinutes()/5)*5).toString().length==2?(parseInt(d.getMinutes()/5)*5).toString():"0"+(parseInt(d.getMinutes()/5)*5).toString())+":00";
  return time_format_str
}
