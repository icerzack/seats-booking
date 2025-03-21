import React, { useEffect, useState } from 'react';
import { getBookingsByUser } from '../api/bookings';

const BookingList = ({ userCode }) => {
    const [bookings, setBookings] = useState([]);

    useEffect(() => {
        const fetchBookings = async () => {
            try {
                const response = await getBookingsByUser(userCode);
                setBookings(response);
            } catch (error) {
                console.error('Failed to fetch bookings:', error);
            }
        };
        fetchBookings();
    }, [userCode]);

    return (
        <div>
            <h2>Your Bookings</h2>
            {bookings?.length > 0 ? (
                <div className="slots-list">
                    {bookings.map(booking => (
                        <div key={booking.id} className="slot-item">
                            <p><strong>Booking ID:</strong> {booking.id}</p>
                            <p><strong>Start Time:</strong> {
                                new Date(booking.startTime).toLocaleString('en-US', {
                                    weekday: 'short',
                                    month: 'short',
                                    day: 'numeric',
                                    year: 'numeric',
                                    hour: '2-digit',
                                    minute: '2-digit'
                                })
                            }</p>
                            <p><strong>End Time:</strong> {
                                new Date(booking.endTime).toLocaleString('en-US', {
                                    weekday: 'short',
                                    month: 'short',
                                    day: 'numeric',
                                    year: 'numeric',
                                    hour: '2-digit',
                                    minute: '2-digit'
                                })
                            }</p>
                            <p><strong>Comment:</strong> {booking.comment || 'None'}</p>
                        </div>
                    ))}
                </div>
            ) : (
                <p className="neomorphic">No bookings found for this code.</p>
            )}
        </div>
    );
};

export default BookingList;