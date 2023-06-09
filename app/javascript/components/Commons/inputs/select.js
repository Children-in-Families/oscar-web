import React, { useEffect, useState } from 'react';
import Select from 'react-select'

export default props => {
  const { value, options, isMulti, isError, isDisabled, label, required, onChange, asGroup, T, hintText, inlineClassName, inline, ...others } = props
  const [selectedOption, setSelectedOption] = useState(null);

  const getSeletedObject = () => {
    if(options) {
      let object        = []
      const optionLists = asGroup && options.map(option => option.options).flat() || options

      optionLists.forEach(option => {
        if (Array.isArray(value)) {
          if (value.includes(option.value))
            object.push(option)
        } else if (option.value == value)
          object = option
      })

      return $.isEmptyObject(object) ? null : object
    }
  }

  useEffect(() => {
    setSelectedOption(getSeletedObject())
  }, [options]);

  const handleChange = (selectedOption, { action, removedValue }) => {
    let data
    let removed = removedValue && removedValue.value

    if (isMulti) {
      switch(action) {
        case 'clear':
          selectedOption = options.filter(option => option.isFixed)
          removed = getSeletedObject().map(data => data.value)
          break
        case 'remove-value':
          if(removedValue.isFixed)
            return
          break
      }
      data = selectedOption === null ? [] : selectedOption.map(option => option.value)
    } else {
      data = action === 'clear' ? null : selectedOption.value
    }

    setSelectedOption(selectedOption)
    onChange({ data, removed, action, type: 'select', options: options, isMulti: isMulti })
  }

  const formatGroupLabel = data => (
    <div>
      <span><b>{data.label}</b></span>
    </div>
  )

  return (
    <div className='row m-b-sm'>
      <div className={inline ? 'col-xs-3' : 'col-xs-12'}>
        <label style={ isError && customError.errorText || { display: 'inline' } } className="m-r-sm">
          { required && <abbr title='required'>* </abbr> }
          { label }
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
      </div>
      <div className={inline ? 'col-xs-9' : 'col-xs-12'}>
        <Select
          isMulti={isMulti}
          isClearable={options.some(v => !v.isFixed)}
          isDisabled={isDisabled}
          defaultValue={selectedOption}
          onChange={handleChange}
          formatGroupLabel={asGroup && formatGroupLabel}
          value={selectedOption}
          options={options}
          { ...others }
          styles={
            Object.assign({},
              customStyles,
              isError && customError
            )
          }
          theme={theme => ({
            ...theme,
            colors: {
              ...theme.colors,
              primary50: '#1ab394',
              primary25: '#1ab394',
              primary: '#1ab394',
            },
          })}
        />
        {isError && <span style={customError.errorText}>{T.translate("validation.cannot_blank")}</span> }
      </div>
    </div>
  )
}

const customStyles = {
  menu: (provided) => ({
    ...provided,
    zIndex: 1031
  }),
  control: (provided, styles) => ({
    ...provided,
    boxShadow: 'none',
    ':hover': {
      ...styles[':hover'],
      borderColor: '#1ab394',
    },
  })
}

const customError = {
  control: (provided) => ({
    ...provided,
    borderColor: 'red',
  }),
  errorText: {
    color: 'red'
  }
}
