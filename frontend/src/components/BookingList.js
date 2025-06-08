import React, { useEffect, useState } from 'react';
import axios from 'axios';
import {deleteBooking, getBookingsByUser, updateBooking} from '../api/bookings';

const BookingList = ({ userCode }) => {
    const [bookings, setBookings] = useState([]);
    const [editingBooking, setEditingBooking] = useState(null);
    const [comment, setComment] = useState('');
    const [isDeleting, setIsDeleting] = useState(false);

    useEffect(() => {
        fetchBookings();
    }, [userCode]);

    const fetchBookings = async () => {
        if (!userCode) return;
        try {
            const response = await getBookingsByUser(userCode);
            setBookings(response);
        } catch (error) {
            console.error('Failed to fetch bookings:', error);
        }
    };

    const handleDelete = async (id) => {
        if (isDeleting) return;

        setIsDeleting(true);
        try {
            await deleteBooking(id)
            setBookings(bookings.filter(booking => booking.id !== id));
        } catch (error) {
            console.error('Failed to delete booking:', error);
            alert('Failed to delete booking. Please try again.');
        } finally {
            setIsDeleting(false);
        }
    };

    const handleUpdate = async (id) => {
        try {
            await updateBooking(id, {
                ...editingBooking,
                comment
            })

            fetchBookings();
            setEditingBooking(null);
            setComment('');
        } catch (error) {
            console.error('Failed to update booking:', error);
            alert('Failed to update booking. Please try again.');
        }
    };

    const startEditing = (booking) => {
        setEditingBooking(booking);
        setComment(booking.comment || '');
    };

    const cancelEditing = () => {
        setEditingBooking(null);
        setComment('');
    };

    return (
        <div>
            <h2>Your Bookings</h2>
            {bookings?.length > 0 ? (
                <div className="slots-list">
                    {bookings.map(booking => (
                        <div key={booking.id} className="slot-item">
                            {editingBooking && editingBooking.id === booking.id ? (
                                // Edit mode
                                <>
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
                                    <div className="form-group">
                                        <label htmlFor={`comment-${booking.id}`}>Comment:</label>
                                        <input
                                            id={`comment-${booking.id}`}
                                            value={comment}
                                            onChange={(e) => setComment(e.target.value)}
                                            className="form-control"
                                        />
                                    </div>
                                    <div className="button-group">
                                        <button
                                            onClick={() => handleUpdate(booking.id)}
                                            className="btn btn-save"
                                        >
                                            Save
                                        </button>
                                        <button
                                            onClick={cancelEditing}
                                            className="btn btn-cancel"
                                        >
                                            Cancel
                                        </button>
                                    </div>
                                </>
                            ) : (
                                // View mode
                                <>
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
                                    <div className="button-group">
                                        <button
                                            onClick={() => startEditing(booking)}
                                            className="btn btn-edit"
                                        >
                                            Edit
                                        </button>
                                        <button
                                            onClick={() => handleDelete(booking.id)}
                                            className="btn btn-delete"
                                            disabled={isDeleting}
                                        >
                                            {isDeleting ? 'Deleting...' : 'Delete'}
                                        </button>
                                    </div>
                                </>
                            )}
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