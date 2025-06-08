import React, { useState, useEffect } from 'react';
import { getAvailableSlots } from '../api/bookings';
import { getAllRooms } from '../api/rooms';

const AvailableSlots = ({ roomId }) => {
    const [date, setDate] = useState('');
    const [slots, setSlots] = useState([]);
    const [, setRoomName] = useState('');
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchRoomData = async () => {
            try {
                const roomsData = await getAllRooms();
                const selectedRoom = roomsData.content.find(room => room.id === roomId);
                if (selectedRoom) {
                    setRoomName(selectedRoom.name);
                }
                setLoading(false);
            } catch (err) {
                setError('Failed to fetch room data');
                setLoading(false);
            }
        };

        fetchRoomData();
    }, [roomId]);

    const handleFetchSlots = async () => {
        try {
            const response = await getAvailableSlots(roomId, date);
            setSlots(response);
        } catch (err) {
            setError('Failed to fetch available slots');
        }
    };

    if (loading) return <div>Loading room information...</div>;
    if (error) return <div className="error-message">{error}</div>;

    return (
        <div>
            <p> Room id: {roomId}</p>
            <div className="date-selector">
                <input
                    type="date"
                    value={date}
                    onChange={(e) => setDate(e.target.value)}
                />
                <button onClick={handleFetchSlots} disabled={!date}>Get Slots</button>
            </div>

            {slots.length > 0 ? (
                <ul className="slots-list">
                    {slots.map((slot, index) => (
                        <li key={index} className="slot-item">
                            <div className={`status-indicator ${slot.booked ? 'booked' : 'available'}`}>
                                {slot.booked ? '✖' : '✓'}
                            </div>
                            <p>Start Time: {slot.startTime}</p>
                            <p>End Time: {slot.endTime}</p>
                            <p>Status: {slot.booked ? 'Booked' : 'Available'}</p>
                        </li>
                    ))}
                </ul>
            ) : (
                <p>No slots available for the selected date</p>
            )}
        </div>
    );
};

export default AvailableSlots;