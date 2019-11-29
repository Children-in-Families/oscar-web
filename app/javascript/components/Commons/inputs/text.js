import React from 'react'

export default props => {
  const { isError, label, required, onChange, value, textArea } = props
  return (
    <div className='form-group'>
      <label style={isError && styles.errorText || {}}>
        { required && <abbr title='required'>* </abbr> }
        {label}
      </label>
      { textArea && <textarea className="form-control col-md-12" style={styles.heightBox}></textarea> ||
        <input
          className='form-control'
          onChange={onChange}
          value={value || ''}
          style={
            Object.assign({},
              isError && styles.errorInput,
              textArea && styles.heightBox
            )
          }
        />
      }
      { isError && <span style={styles.errorText}>Cannot be blank.</span> }
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
}
