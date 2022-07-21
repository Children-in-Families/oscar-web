import React from 'react'

export default props => {
  const { isError, label, required, onChange, value, hintText, errorText, T, inlineClassName, inline, ...others } = props

  return (
    <div className='form-group' style={inline && styles.inlineWrapper}>
      <label style={isError && styles.errorText || styles.inlineDisplay}>
        { required && <abbr title='required'>* </abbr> }
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
  inlineWrapper: {
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center'
  },
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
