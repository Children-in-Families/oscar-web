import React from 'react'

export default props => {
  const { step } = props

  return (
    step === 2 &&
    <div>
      <h1>Living Details</h1>
    </div>
  )
}