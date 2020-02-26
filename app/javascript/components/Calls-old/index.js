import React, { Component } from 'react';
import { Link } from 'react-router-dom';

class Calls extends Component {
  constructor(props) {
    super(props)
    this.state = {
      calls: []
    }
  }

  getCalls() {
    const url = "/api/v1/calls";
    // const csrfToken = document.querySelector("meta[name=csrf-token]").content;
    fetch(url
    )
      .then(response => {
        if (response.ok) {
          return response.json();
        }
        throw new Error("Network response was not ok.");
      })
      .then(response => {
        this.setState({ calls: response.calls })
        })
      .catch(error => {
        error.then(err => {
          console.log('err: ', err);
        });
      });
  }

  componentDidMount() {
    this.getCalls();
  }

  render() {
    const { calls } = this.state;
    const allCalls = calls.map((call, index) => (
      <tr key={index}>
        <td>{call.phone_call_id}</td>
        <td>{call.call_type}</td>
      </tr>
    ));
    const noCall = (
      <tr>
        <td colSpan="2">No call</td>
      </tr>
    );

    return (  
      <div className="row">
        <div className="col-xs-12">
          <div className="ibox">
            <div className="ibox-title">
              <div className="ibox-tools">
                <a href="/calls/new" className="btn btn-primary btn-add">Create New Call</a>
              </div>
            </div>
            <div className="ibox-content">
              <div className="table-responsive">
                <table className="table table-bordered table-striped table-hover">
                  <thead>
                    <tr>
                      <th>Phone Call ID</th>
                      <th>Call Type</th>
                    </tr>
                  </thead>
                  <tbody>
                    { calls.length > 0 ? allCalls : noCall }
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>

    )
  }
}

export default Calls
