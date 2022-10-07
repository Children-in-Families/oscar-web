import React, { useState } from 'react'

export default props => {
  const { isError, hidden, label, required, onChange, T, value, hintText, inlineClassName, ...others } = props
  const [values, setValue] = useState(value)

  const handleInput = (e) => {
    setValue(e.target.value)
    onChange(e)
  }

  return (
    <div className='form-group'>
      <label className={ hidden ? 'hidden' : '' } style={isError && styles.errorLabel || {}}>
        {required && <abbr title='required'>* </abbr>}
        {label}
      </label>
      {
        inlineClassName &&
        hintText &&
        <a
          tabIndex="0"
          data-toggle="popover"
          role="button"
          data-html="true"
          data-placement="bottom"
          data-trigger="focus"
          data-content={ hintText }>
          <i className={`fa fa-info-circle text-info m-xs ${inlineClassName}`}></i>
        </a>
      }
      <textarea className="form-control col-xs-12" style={styles.heightBox} onChange={handleInput} {...others} value={values || ''} />
      {isError && <span style={styles.errorText}>{T.translate("validation.cannot_blank")}</span>}
    </div>
  )
}

const styles = {
  errorLabel: {
    color: 'red'
  },
  errorText: {
    color: 'red',
    display: 'block'
  },
  errorInput: {
    borderColor: 'red'
  },
  heightBox: {
    height: '100px'
  }
}
