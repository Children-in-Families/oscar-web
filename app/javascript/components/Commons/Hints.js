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
      element: '.referree-province',
      hint: hintText.referee.referral_province,
      ...hintPosition
    },
    {
      element: '.referree-districs',
      hint: hintText.referee.referral_districs,
      ...hintPosition
    },
    {
      element: '.referree-commune',
      hint: hintText.referee.referral_commune,
      ...hintPosition
    },
    {
      element: '.village',
      hint: hintText.address.village,
      ...hintPosition
    },
    {
      element: '.referree-street-number',
      hint: hintText.referee.referral_street_number,
      ...hintPosition
    },
    {
      element: '.referree-house-number',
      hint: hintText.referee.referral_house_number,
      ...hintPosition
    },
    {
      element: '.referree-address-name',
      hint: hintText.referee.referral_address_name,
      ...hintPosition
    },
    {
      element: '.referree-address-type',
      hint: hintText.referee.referral_address_type,
      ...hintPosition
    },
    {
      element: '.given-name',
      hint: hintText.referral.given_name,
      ...hintPosition
    },
    {
      element: '.family-name',
      hint: hintText.referral.family_name,
      ...hintPosition
    },
    {
      element: '.local-given-name',
      hint: hintText.referral.local_given_name,
      ...hintPosition
    },
    {
      element: '.local-family-name',
      hint: hintText.referral.local_family_name,
      ...hintPosition
    },
    {
      element: '.client-gender',
      hint: hintText.referral.client_gender,
      ...hintPosition
    },
    {
      element: '.client-date-of-birth',
      hint: hintText.referral.client_dat_of_birth,
      ...hintPosition
    },
    {
      element: '.client-birth-province',
      hint: hintText.referral.client_birth_province,
      ...hintPosition
    },
    {
      element: '.client-relationship',
      hint: hintText.referral.client_relationship,
      ...hintPosition
    },
    {
      element: '.client-is-outside',
      hint: hintText.referral.client_is_outside,
      ...hintPosition
    },
    {
      element: '.what-3-word',
      hint: hintText.referral.what_3_word,
      ...hintPosition
    },
    {
      element: '.client-phone',
      hint: hintText.referral.client_phone,
      ...hintPosition
    },

  ]

  return (
    <Hints enabled={enabled} hints={hints} options={hintOptions} />
  )
}

export default hints