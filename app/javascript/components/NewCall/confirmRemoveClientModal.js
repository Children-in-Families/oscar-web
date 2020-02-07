import React from "react";

export default props => {
  const {
    onClick,
    closeAction,
    data: { T }
  } = props;

  const handleClickYes = () => {
    onClick();
  };

  return (
    <>
      <div className="row">
        <div className="col-xs-12">
          <p>{T.translate("newCall.confirmRemoveClientModal.are_you_sure")}</p>
        </div>
        <div className="col-xs-12 text-right">
          <button className="btn btn-default form-btn" onClick={closeAction}>
            {T.translate("newCall.confirmRemoveClientModal.no")}
          </button>
          <button
            className="btn btn-primary form-btn"
            onClick={handleClickYes}
          >
            {T.translate("newCall.confirmRemoveClientModal.yes")}
          </button>
        </div>
      </div>
    </>
  );
};
