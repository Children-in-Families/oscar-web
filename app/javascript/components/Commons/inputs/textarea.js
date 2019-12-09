import React from 'react'

export default props => {
  const { isError, label, required, onChange, ...others } = props
  return (
    <div className='form-group'>
      <label style={isError && styles.errorText || {}}>
        {required && <abbr title='required'>* </abbr>}
        {label}
      </label>
      <textarea className="form-control col-md-12" style={styles.heightBox} onChange={onChange} {...others} />
      {isError && <span style={styles.errorText}>Cannot be blank.</span>}
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
  heightBox: {
    height: '100px'
  }
}
