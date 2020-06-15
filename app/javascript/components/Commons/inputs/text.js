import React from 'react'

export default props => {
  const { isError, label, required, onChange, value, errorText, T, inlineClassName, ...others } = props

  return (
    <div className='form-group'>
      <label style={isError && styles.errorText || styles.inlineDisplay}>
        { required && <abbr title='required'>* </abbr> }
        {label}
      </label>
      { inlineClassName && <i className={`fa fa-info-circle text-info m-xs ${inlineClassName}`}></i> }
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
      { isError && <span style={styles.errorText}>{errorText || T.translate("validation.cannot_blank")}</span> }
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
    boxShadow: 'none',
    lineHeight: 'inherit'
  },
  inlineDisplay: {
    display: 'inline'
  }
}
