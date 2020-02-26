import React from 'react'
import Modal from 'react-modal'

const modal = props => {
  const { content, footer, isOpen, type, closeAction, title } = props

  const styles = {
    modalHeader: {
      backgroundColor: type === 'warning' ? '#f8ac59' : '#18a689',
      color: 'white',
      padding: 10,
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      fontWeight: 'bold'
    },
    modalContent: {
      padding: 10
    },
    modalFooter: {
      padding: 10
    },
    close: {
      cursor: 'pointer'
    }
  }

  return (
    <Modal
      isOpen={isOpen}
      // onRequestClose={closeAction}
      ariaHideApp={false}
      style={customStyles}
    >
      <div style={styles.modalHeader}>
        <span>{title}</span>
        <span style={styles.close} onClick={closeAction}>&#10006;</span>
      </div>

      <div style={styles.modalContent}>
        {content}
      </div>

      {
        footer &&
        <>
          <hr />
          <div style={styles.modalFooter}>
            {footer}
          </div>
        </>
      }
    </Modal>
  )
}

const customStyles = {
  overlay: {
    zIndex: 3000,
    backgroundColor: 'rgba(0, 0, 0, 0.75)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center'
  },
  content: {
    width: '40%',
    top: 'unset',
    bottom: 'unset',
    left: 'unset',
    right: 'unset',
    padding: 0,
    border: 'none'
  }

}

export default modal