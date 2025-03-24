import axios from 'axios';
import { createBooking, getBookingsByUser, getAvailableSlots } from '../bookings';

jest.mock('axios');

describe('Bookings API', () => {
    const API_URL = 'http://77.244.220.121:10101/api/v1';

    afterEach(() => {
        jest.resetAllMocks();
    });

    describe('createBooking', () => {
        it('calls axios with correct parameters and returns response', async () => {
            const bookingData = { roomId: 1, date: '2023-10-15', startTime: '10:00', endTime: '11:00' };
            const mockResponse = { data: { id: 1, ...bookingData } };
            axios.post.mockResolvedValue(mockResponse);

            const result = await createBooking(bookingData);

            expect(axios.post).toHaveBeenCalledWith(`${API_URL}/bookings`, bookingData);
            expect(result).toEqual(mockResponse);
        });
    });

    describe('getBookingsByUser', () => {
        it('calls axios with correct parameters and returns data', async () => {
            const code = 'ABC123';
            const mockResponse = { data: [{ id: 1 }, { id: 2 }] };
            axios.get.mockResolvedValue(mockResponse);

            const result = await getBookingsByUser(code);

            expect(axios.get).toHaveBeenCalledWith(`${API_URL}/bookings/code`, { params: { code } });
            expect(result).toEqual(mockResponse.data);
        });
    });

    describe('getAvailableSlots', () => {
        it('calls axios with correct parameters and returns data', async () => {
            const roomId = 1;
            const date = '2023-10-15';
            const mockResponse = { data: ['10:00', '11:00', '12:00'] };
            axios.get.mockResolvedValue(mockResponse);

            const result = await getAvailableSlots(roomId, date);

            expect(axios.get).toHaveBeenCalledWith(
                `${API_URL}/bookings/room/${roomId}/availability`,
                { params: { date } }
            );
            expect(result).toEqual(mockResponse.data);
        });
    });
});