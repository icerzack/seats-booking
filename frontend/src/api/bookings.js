import axios from 'axios';

const API_URL = 'http://localhost:10101/api/v1';

export const createBooking = async (bookingData) => {
    const response = await axios.post(`${API_URL}/bookings`, bookingData);
    return response;
};

export const getBookingsByUser = async (code) => {
    const response = await axios.get(`${API_URL}/bookings/code`, { params: { code } });
    return response.data;
};

export const getAvailableSlots = async (roomId, date) => {
    const response = await axios.get(`${API_URL}/bookings/room/${roomId}/availability`, { params: { date } });
    return response.data;
};