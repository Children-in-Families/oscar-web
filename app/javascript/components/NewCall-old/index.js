import React, { Component } from 'react';

class NewCall extends Component {
  constructor(props) {
    super(props);
    this.state = {
      phone_call_id: "",
      start_datetime: "",
      end_datetime: "",
      receiving_staff_id: "",
      call_type: ""
    };
    this.onChange = this.onChange.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
  }

  onChange(event) {
    this.setState({ [event.target.name]: event.target.value });
  }

  onSubmit(event) {
    event.preventDefault();
    const url = "/api/v1/calls";
    const { phone_call_id, start_datetime, end_datetime, receiving_staff_id, call_type } = this.state;
    // if (phone_call_id.length == 0 || call_type.length == 0)
    //   return;

    const body = {
      phone_call_id,
      start_datetime,
      end_datetime,
      receiving_staff_id,
      call_type
    };

    const token = document.querySelector('meta[name="csrf-token"]').content;
    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": token,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(body)
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        }
        throw response.json();
      })
      .then(response => {
        console.log('success response: ', response);
        window.location.href = '/calls';
      })
      .catch(error => {
        error.then(err => {
          console.log('err: ', err);
        });
      });
  }

  render() {
    const callTypes = [
      { label: 'New Referral: Case Action Required', value: 'case_action_required' },
      { label: 'New Referral: Notifier Concern', value: 'notifier_concern' },
      { label: 'Providing Update', value: 'providing_update' },
      { label: 'Phone Counseling', value: 'phone_counseling' },
      { label: 'Seeking Information', value: 'seeking_information' },
      { label: 'Spam Call', value: 'spam_call' },
      { label: 'Wrong Number', value: 'wrong_number' }
    ];
    const callTypeOpts = callTypes.map((callType, index) =>(
      <option key={index} value={callType.value}>{callType.label}</option>
    ));

    return (
      <div className="container mt-5">
        <div className="row">
          <div className="col-sm-12 col-lg-6 offset-lg-3">
            <h1 className="font-weight-normal mb-5">
              New Call
            </h1>
            <form onSubmit={this.onSubmit}>
              <div className="form-group">
                <label htmlFor="callPhoneCallId">Phone Call ID</label>
                <input
                  type="text"
                  name="phone_call_id"
                  id="callPhoneCallId"
                  className="form-control"
                  onChange={this.onChange}
                />
              </div>
              <div className="form-group">
                <label htmlFor="callCallType">Call Type</label>
                <select name="call_type" id="callCallType" className="form-control" onChange={this.onChange}>
                  { callTypeOpts }
                </select>

              </div>
              <div className="form-group">
                <label htmlFor="callStartDatetime">Start Datetime</label>
                <input
                  type="text"
                  name="start_datetime"
                  id="callStartDatetime"
                  className="form-control"
                  onChange={this.onChange}
                />
              </div>
              <div className="form-group">
                <label htmlFor="callEndDatetime">End Datetime</label>
                <input
                  type="text"
                  name="end_datetime"
                  id="callEndDatetime"
                  className="form-control"
                  onChange={this.onChange}
                />
              </div>
              <div className="form-group">
                <label htmlFor="callReceivingStaffId">Receiving Staff Id</label>
                <input
                  type="text"
                  name="receiving_staff_id"
                  id="callReceivingStaffId"
                  className="form-control"
                  onChange={this.onChange}
                />
              </div>
              <button type="submit" className="btn btn-primary form-btn">
                Create Call
              </button>
            </form>
          </div>
        </div>
      </div>
    );
  }
}

export default NewCall
