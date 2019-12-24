import React from 'react'

export default props => {
  const { isError, label, required, onChange, value, errorText, ...others } = props
  return (
    <div className='form-group'>
      <label style={isError && styles.errorText || {}}>
        { required && <abbr title='required'>* </abbr> }
        {label}
      </label>
      <input
        className='form-control'
        onChange={onChange}
        { ...others }
        value={value || ''}
        style={
          Object.assign({},
            isError && styles.errorInput,
            styles.box
          )
        }
      />
      { isError && <span style={styles.errorText}>{errorText || 'Cannot be blank.'}</span> }
    </div>
  )
}

const styles = {
  errorText: {
    color: 'red'
  },
  errorInput: {
    borderColor: 'red'
  },
  box: {
    boxShadow: 'none'
  }
}
