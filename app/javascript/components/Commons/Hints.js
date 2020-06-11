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
      element: '.admin-receiving-staff',
      hint: hintText.admin.admin_receiving_staff,
      ...hintPosition
    },
    {
      element: '.admin-referral-date',
      hint: hintText.admin.admin_referral_date,
      ...hintPosition
    },
    {
      element: '.case-worker',
      hint: hintText.admin.case_worker,
      ...hintPosition
    },
    {
      element: '.first-follow-by',
      hint: hintText.admin.first_follow_by,
      ...hintPosition
    },
    {
      element: '.first-follow-date',
      hint: hintText.admin.first_follow_date,
      ...hintPosition
    },
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
    {
      element: '.referee-gender',
      hint: hintText.referee.gender,
      ...hintPosition
    },
    {
      element: '.referee-email',
      hint: hintText.referee.email,
      ...hintPosition
    },
    {
      element: '.referral-source-category',
      hint: hintText.referee.referral_source_category,
      ...hintPosition
    },
    {
      element: '.referral-source',
      hint: hintText.referee.referral_source,
      ...hintPosition
    },
    {
      element: '.referral-province',
      hint: hintText.referee.referral_province,
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