import React from 'react'

export default props => {
  const { step } = props

  return (
    step === 3 &&
    <div>
      <h1>Other Details</h1>
    </div>
  )
}