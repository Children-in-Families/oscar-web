import React from 'react'

export default props => {
  const { isError, hidden, label, required, onChange, T, value, hintText, inlineClassName, ...others } = props
  return (
    <div className='form-group'>
      <label className={ hidden ? 'hidden' : '' } style={isError && styles.errorText || {}}>
        {required && <abbr title='required'>* </abbr>}
        {label}
      </label>
      {
        inlineClassName &&
        <a
          tabIndex="0"
          data-toggle="popover"
          role="button"
          data-html="true"
          data-placement="bottom"
          data-trigger="focus"
          data-content={ hintText || 'N/A' }>
          <i className={`fa fa-info-circle text-info m-xs ${inlineClassName}`}></i>
        </a>
      }
      <textarea className="form-control col-xs-12" style={styles.heightBox} onChange={onChange} {...others} value={value || ''} />
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
