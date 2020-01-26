import React, { useEffect, useState } from "react"
import { TextInput, DateInput } from "../Commons/inputs"
import Modal from '../Commons/Modal'

export default props => {
  const { data: { referee, clientTask }, onChange } = props
  const [invalid, setInvalid] = useState(false)
  const [isOpen, setIsOpen]   = useState(referee.requested_update || false)
  const initialData = {
    name: '',
    completion_date: null,
    relation: 'case_note'
  }
  // currently only one task will be created
  const [task, setTask]     = useState(clientTask || initialData)

  useEffect(() => {
    setIsOpen(referee.requested_update || false)
  }, [referee.requested_update])

  // const deleteTask = index => setTasks(tasks.filter((task, taskIndex) => taskIndex !== index))

  // const onChangeDate = index => data => modifyObject(index, { completion_date: data.data })
  const onChangeDate = data => setTask({...task, completion_date: data.data})
  // const onChangeText = index => event => modifyObject(index, { name: event.target.value })
  const onChangeText = () => setTask({...task, name: event.target.value})

  // const modifyObject = (index, field) => {
  //   const getObject    = tasks[index]
  //   const modifyObject = { ...getObject, ...field }

  //   const newObjects = tasks.map((object, indexObject) => {
  //     const newObject = indexObject === index ? modifyObject : object
  //     return newObject
  //   })

  //   setTasks(newObjects)
  // }

  const saveTasks = () => {
    // const invalid = tasks.some(task => task.name === '' || task.completion_date === null )

    if(task.completion_date === null)
      setInvalid(true)
    else {
      onChange('task', { ...task })({type: 'select'})
      setIsOpen(false)
    }
  }

  const renderContent = () => {
    return (
      <div style={{minHeight: 300}}>
        { invalid && <p style={{color: 'red'}}>Please Input all the required fields</p> }
        <div style={styles.modalContentWrapper}>
          <DateInput required label='Completion Date' onChange={onChangeDate} value={task.completion_date} />
          <TextInput required disabled={true} label='Task Details' value={task.name || `Call ${referee.name} on ${referee.phone} to update about the client.`} />
          <TextInput required disabled={true} label='Domain' value='Domain 3B' />
        </div>
        {/* below code is for multiple tasks. Delete if client decide to never use multiple tasks */}
        {/* {
          tasks.map((task, index) => (
            <div key={index} style={styles.modalContentWrapper}>
              <TextInput required label='Task Details' onChange={onChangeText(index)} value={task.name} />
              <DateInput required label='Completion Date' onChange={onChangeDate(index)} value={task.completion_date} />
              <button style={{marginTop: 10}} className='btn btn-danger' onClick={() => deleteTask(index)}>Delete</button>
            </div>
          ))
        }
        <button className='btn btn-primary' onClick={() => setTasks([...tasks, initialData])}>Add Task</button> */}
      </div>
    )
  }

  const renderFooter = () => {
    return (
      <div style={{display:'flex', justifyContent: 'flex-end'}}>
        <button style={{margin: 5}} className='btn btn-primary' onClick={saveTasks}>Save</button>
        <button style={{margin: 5}} className='btn btn-default' onClick={() => setIsOpen(false)}>Cancel</button>
        {/* <button style={{margin: 5}} className='btn btn-default' onClick={() => onChange("referee", { requested_update: false })({type: 'checkbox'})}>Cancel</button> */}
      </div>
    )
  }

  return (
    <Modal
      title='Add New Tasks'
      isOpen={isOpen}
      type='success'
      closeAction={() => setIsOpen(false)}
      content={renderContent()}
      footer={renderFooter()}
    />
  )
}

const styles = {
  // modalContentWrapper: {
  //   display: 'flex',
  //   alignItems: 'center',
  //   justifyContent: 'space-around'
  // }
  modalContentWrapper: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    padding: 10
  }
}
