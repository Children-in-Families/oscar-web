import React from 'react'

export default props => {
  const { isError, hidden, label, required, onChange, T, ...others } = props
  return (
    <div className='form-group'>
      <label className={ hidden ? 'hidden' : '' } style={isError && styles.errorText || {}}>
        {required && <abbr title='required'>* </abbr>}
        {label}
      </label>
      <textarea className="form-control col-xs-12" style={styles.heightBox} onChange={onChange} {...others} />
      {isError && <span style={styles.errorText}>{T.translate("validation.cannot_blank")}</span>}
    </div>
  )
}

const styles = {
  errorText: {
    color: 'red',
    width: '100%'
  },
  errorInput: {
    borderColor: 'red'
  },
  heightBox: {
    height: '100px'
  }
}
