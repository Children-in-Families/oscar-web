import React from 'react'
import { Steps, Hints } from 'intro.js-react';

const hints = props => {
  const { helpText, enabled } = props

  const hintOptions = {
    hintAnimation: false,
    showButtons: false
  }

  const hintPosition = {
    hintPosition: 'middle-middle'
  }
  const hintText = JSON.parse(helpText)
  const hints = [
    {
      element: '.referee-name',
      hint: hintText.referee.name,
      ...hintPosition
    },
    {
      element: '.referee-phone',
      hint: hintText.referee.phone,
      ...hintPosition
    },
  ]

  const clientHints = [
    {
      element: '.client-givent-name',
      hint: 'test hint 1',
      ...hintPosition
    },
    {
      element: '.client-family-name',
      hint: 'test hint 2',
      ...hintPosition
    },
  ]

  return (
    <Hints enabled={enabled} hints={hints} options={hintOptions} />
  )
}

export default hints