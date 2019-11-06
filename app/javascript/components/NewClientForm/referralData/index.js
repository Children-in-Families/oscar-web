import React from 'react'

export default props => {
  const { step } = props

  return (
    step === 4 &&
    <div>
      <h1>Specifi Points of Refferal Data</h1>
    </div>
  )
}