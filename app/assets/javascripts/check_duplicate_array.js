Array.prototype.getDuplicates = function () {
  var duplicates = {};
  for (var i = 0; i < this.length; i++) {
    if(duplicates.hasOwnProperty(this[i])) {
      duplicates[this[i]].push(i);
    } else if (this.lastIndexOf(this[i]) !== i) {
      duplicates[this[i]] = [i];
    }
  }

  return duplicates;
};

Array.prototype.elementWitoutDuplicates = function () {
  var noneDuplicates = []
  var duplicates = Object.values(this.getDuplicates())
  var combine = [].concat.apply([], duplicates)
  this.map(function (val, index){
    if (!combine.includes(index)){
      noneDuplicates.push(val)
    }
  });
  
  return noneDuplicates;
};
