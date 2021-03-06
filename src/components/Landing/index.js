import React from 'react';
import { Link } from 'react-router-dom';

import './stylesheet.css';
import logo from '../../images/organice.svg';

export default () => {
  return (
    <main className="landing-container-wrapper">
      <div className="landing-container">
        <h1 className="landing-app-name">organice</h1>

        <img className="landing-logo" src={logo} alt="Logo" />

        <h2 className="landing-tagline">organice organizes Org files nicely!</h2>

        <h2 className="landing-tagline">
          Syncs with Dropbox,
          <br /> Google Drive and WebDAV.
        </h2>

        <p className="landing-description">
          organice allows you to view and edit Org files from cloud storage directly on your device!
          No Org file or other user-data will be stored on our servers; the entire app is
          browser-based.
        </p>

        <Link to="/sample">
          <div className="btn landing-button view-sample-button">View sample</div>
        </Link>
        <Link to="/sign_in">
          <div className="btn landing-button">Sign in</div>
        </Link>
      </div>
      <footer>
        <Link to="/privacy-policy">Privacy Policy</Link>
      </footer>
    </main>
  );
};
