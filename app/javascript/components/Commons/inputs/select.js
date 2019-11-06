import React from 'react'

export default props => {
  const renderGroupOption = collections => {
    return (
      collections.map((collection, index) => (
          <optgroup key={index} label={collection[0]} >
            {renderOptions(collection[1])}
          </optgroup>
        )
      )
    )
  }

  const renderOptions = collections => (
    collections.map((collection, index) =>(
      <option
        key={index}
        value={collection[1]}
      >
        { collection[0] }
      </option>
    ))
  )

  return (
    <div className='form-group'>
      <label>
        { props.required && <abbr title='required'>* </abbr> }
        {props.label}
      </label>
      <select style={styles.select} multiple={props.multiple}>
        { props.asGroup && renderGroupOption(props.collections) || renderOptions(props.collections)}
      </select>
    </div>
  )
}

const styles = {
  select: {
    width: '100%'
  }
}