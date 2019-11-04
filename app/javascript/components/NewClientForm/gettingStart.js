import React from 'react'

export default props => {
  const { step } = props
  
  return (
    step === 1 &&
    <div>
      <h1>Getting Start</h1>
    </div>
  )
}