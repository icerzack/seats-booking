import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import AvailableSlots from '../components/AvailableSlots';
import { getAllRooms } from '../api/rooms';

const RoomsPage = () => {
    const [rooms, setRooms] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [selectedRoomId, setSelectedRoomId] = useState('');

    useEffect(() => {
        const fetchRooms = async () => {
            try {
                const roomsData = await getAllRooms();
                setRooms(roomsData.content);
                // Set the first room as selected by default if available
                if (roomsData.content && roomsData.content.length > 0) {
                    setSelectedRoomId(roomsData.content[0].id);
                }
                setLoading(false);
            } catch (err) {
                setError('Failed to fetch rooms');
                setLoading(false);
            }
        };

        fetchRooms();
    }, []);

    const handleRoomChange = (e) => {
        setSelectedRoomId(e.target.value);
    };

    if (loading) return <div>Loading rooms...</div>;
    if (error) return <div className="error-message">{error}</div>;

    return (
        <div className="">
            <Link to="/" className="nav-link back-button">Back to Home</Link>
            <h1>Check Room Availability</h1>

            {rooms.length === 0 ? (
                <p>No rooms available</p>
            ) : (
                <div>
                    <div className="room-selector">
                        <label htmlFor="room-select">Select a room:</label>
                        <div className="">
                            <select
                                id="room-select"
                                value={selectedRoomId}
                                onChange={handleRoomChange}
                            >
                                {rooms.map(room => (
                                    <option key={room.id} value={room.id}>
                                        {room.name}
                                    </option>
                                ))}
                            </select>
                        </div>
                    </div>

                    {selectedRoomId && <AvailableSlots roomId={selectedRoomId} />}
                </div>
            )}
        </div>
    )
};

export default RoomsPage;