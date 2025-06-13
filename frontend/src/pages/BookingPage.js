import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import BookingForm from '../components/BookingForm';
import BookingList from '../components/BookingList';

const BookingPage = () => {
    const [userCode, setUserCode] = useState('');
    const [requestedCode, setRequestedCode] = useState('');

    const handleBookingCreated = (code) => {
        setUserCode(code);
    };

    return (
        <div className="">
            <Link to="/" className="nav-link back-button">Back to Home</Link>
            <h1>Book a Room</h1>
            <BookingForm onSubmit={handleBookingCreated} />
            {userCode !== '' &&
                <div>
                    <h2>Personal code:</h2>
                    <p> {userCode} </p>
                </div>
            }

            <h2>Check Your Bookings</h2>
            <div className="">
                <div className="code-input-container">
                    <input
                        id="booking-code"
                        type="text"
                        placeholder="Enter your code"
                        value={requestedCode}
                        onChange={(e) => {
                            const code = e.target.value;
                            setRequestedCode(code);
                        }}
                        className="input"
                    />
                </div>
            </div>

            <BookingList userCode={requestedCode} />
        </div>
    );
};

export default BookingPage;