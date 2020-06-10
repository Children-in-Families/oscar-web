import React from 'react'
import LoadingScreen from 'react-loading-screen'

const Loading = props => {
  const { text, loading, ...others } = props

  return (
    <div className="loading-screen">
      <LoadingScreen
        loading={loading}
        bgColor='#fff'
        spinnerColor='#9ee5f8'
        textColor='#676767'
        text={text}
        {...others}
      >
      </LoadingScreen>
    </div>
  )
}

export default Loading
