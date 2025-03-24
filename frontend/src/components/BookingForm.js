import React, {useEffect, useState} from 'react';
import { createBooking } from '../api/bookings';
import {getAllRooms} from "../api/rooms";

const BookingForm = ({ onSubmit }) => {
    const [rooms, setRooms] = useState([]);
    const [selectedRoomId, setSelectedRoomId] = useState('');
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const [formData, setFormData] = useState({
        roomId: '',
        fio: '',
        startTime: '',
        endTime: '',
        comment: ''
    });

    useEffect(() => {
        const fetchRooms = async () => {
            try {
                const roomsData = await getAllRooms();
                setRooms(roomsData.content);
                // Set the first room as selected by default if available
                if (roomsData.content && roomsData.content.length > 0) {
                    setSelectedRoomId(roomsData.content[0].id);
                }
                setFormData({ ...formData, roomId: roomsData.content[0].id });
                setLoading(false);
            } catch (err) {
                setError('Failed to fetch rooms');
                setLoading(false);
            }
        };

        fetchRooms();
    }, []);

    const handleChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const response = await createBooking(formData);
            onSubmit(response.data.code);
            alert('Booking created successfully!');
        } catch (error) {
            let errorMessage = 'Failed to create booking';
            if (error.response) {
                errorMessage += ': ' + (error.response.data || error.response.statusText);
            } else if (error.message) {
                errorMessage += ': ' + error.message;
            }
            alert(errorMessage);
        }
    };

    if (loading) return <div>Loading rooms...</div>;
    if (error) return <div className="error-message">{error}</div>;

    return (
        <form onSubmit={handleSubmit}>
            <div className="room-selector">
                <label htmlFor="room-select">Select a room:</label>
                <select
                    id="room-select"
                    name="roomId"
                    defaultValue={selectedRoomId}
                    onChange={handleChange}
                    required
                >
                    {rooms.map(room => (
                        <option key={room.id} value={room.id}>
                            {room.name}
                        </option>
                    ))}
                </select>
            </div>
            <input
                name="fio"
                value={formData.fio}
                onChange={handleChange}
                placeholder="Full Name"
                required
            />
            <input
                type="date"
                name="startDate"
                value={formData.startTime ? formData.startTime.split('T')[0] : ''}
                onChange={(e) => {
                    const time = formData.startTime ? formData.startTime.split('T')[1] : '09:00';
                    setFormData({...formData, startTime: `${e.target.value}T${time}`});
                }}
                min="2024-01-01"
                max="2030-12-31"
                required
            />
            <select
                name="startHour"
                value={formData.startTime ? formData.startTime.split('T')[1].substring(0, 5) : '09:00'}
                onChange={(e) => {
                    const date = formData.startTime ? formData.startTime.split('T')[0] : new Date().toISOString().split('T')[0];
                    setFormData({...formData, startTime: `${date}T${e.target.value}`});
                }}
                required
            >
                {Array.from({length: 10}, (_, i) => i + 9).map(hour => (
                    <option key={hour} value={`${hour}:00`}>{hour}:00</option>
                ))}
            </select>
            <input
                type="date"
                name="endDate"
                value={formData.endTime ? formData.endTime.split('T')[0] : ''}
                onChange={(e) => {
                    const time = formData.endTime ? formData.endTime.split('T')[1] : '10:00';
                    setFormData({...formData, endTime: `${e.target.value}T${time}`});
                }}
                min="2024-01-01"
                max="2030-12-31"
                required
            />
            <select
                name="endHour"
                value={formData.endTime ? formData.endTime.split('T')[1].substring(0, 5) : '10:00'}
                onChange={(e) => {
                    const date = formData.endTime ? formData.endTime.split('T')[0] : new Date().toISOString().split('T')[0];
                    setFormData({...formData, endTime: `${date}T${e.target.value}`});
                }}
                required
            >
                {Array.from({length: 10}, (_, i) => i + 9).map(hour => (
                    <option key={hour} value={`${hour}:00`}>{hour}:00</option>
                ))}
            </select>
            <input
                name="comment"
                value={formData.comment}
                onChange={handleChange}
                placeholder="Comment"
            />
            <button type="submit">Create Booking</button>
        </form>
    );
};

export default BookingForm;