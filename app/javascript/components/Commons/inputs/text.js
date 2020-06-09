import React from 'react'
import { Steps, Hints } from 'intro.js-react';

export default props => {
  const { isError, label, required, onChange, value, errorText, T, inlineClassName, ...others } = props

  const hints = [
    {
      element: '.selector1',
      hint: 'test hint 1',
      hintPosition: 'middle-middle'
    },
    {
      element: '.referee-phone',
      hint: 'test hint 2',
      hintPosition: 'middle-middle'
    },
  ]

  const hintOptions = {
    hintAnimation: false
  }

  return (
    <div className='form-group'>
      <label style={isError && styles.errorText || {}}>
        { required && <abbr title='required'>* </abbr> }
        {label}
      </label>
      <i className={`fa fa-info-circle text-info m-xs ${inlineClassName}`}></i>
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
      <Hints enabled={true} hints={hints} options={hintOptions} />
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
  }
}
