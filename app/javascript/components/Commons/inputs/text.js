import React, { useState, useEffect } from 'react'
import introJs from 'intro.js';

export default props => {
  const { isError, label, required, onChange, value, errorText, T, inlineClassName, ...others } = props

  const [ hint, setHint ] = useState(true);

  useEffect(() => {
    setTimeout(() => {
      setHint(false);
      introJs().setOptions({ hintPosition: 'middle-middle', hintAnimation: false }).addHints();
    }, 1000)
  }, []);

  const handleShowHint = (hint) => {
    const hintOption = {
      hint: hint,
      element: `.${inlineClassName}`,
      hintPosition: 'middle-middle',
      hintAnimation: false
    }
  }

  return (
    <div className='form-group'>
      <label style={isError && styles.errorText || styles.inlineDisplay}>
        { required && <abbr title='required'>* </abbr> }
        {label}
      </label>
      {
        inlineClassName &&
        <i
          className={`fa fa-info-circle text-info m-xs ${inlineClassName}`}
          data-hint={'Hello world!'}
          onClick={ () => handleShowHint() }
        ></i>
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
