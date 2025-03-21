import React from 'react';
import { Link, useLocation } from 'react-router-dom';

const HomePage = () => {
    const location = useLocation();

    return (
        <div className="">
            <h1>Welcome</h1>
            {location.pathname !== '/' && (
                <Link to="/" className="nav-link back-button">Back to Home</Link>
            )}
            <div className="nav-row">
                <Link to="/bookings" className="nav-link">My Bookings</Link>
                <Link to="/rooms" className="nav-link">Rooms</Link>
            </div>
        </div>
    );
};

export default HomePage;