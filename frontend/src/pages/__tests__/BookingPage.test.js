import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import BookingPage from '../BookingPage';
import { getAllRooms } from '../../api/rooms';
import { createBooking } from '../../api/bookings';

jest.mock('../../api/rooms');
jest.mock('../../api/bookings');
jest.mock('../../api/bookings', () => ({
    ...jest.requireActual('../../api/bookings'),
    createBooking: jest.fn(),
    getBookingsByUser: jest.fn()
}));

const mockNavigate = jest.fn();
jest.mock('react-router-dom', () => ({
    ...jest.requireActual('react-router-dom'),
    useNavigate: () => mockNavigate
}));

describe('BookingPage', () => {
    const mockRooms = {
        content: [
            { id: 1, name: 'Conference Room' },
            { id: 2, name: 'Meeting Room' }
        ]
    };

    beforeEach(() => {
        jest.clearAllMocks();

        getAllRooms.mockResolvedValue(mockRooms);
        createBooking.mockResolvedValue({ data: { code: 'ABC123' } });

        jest.spyOn(window, 'alert').mockImplementation(() => {});
    });

    it('renders the booking page with header and form', async () => {
        render(
            <MemoryRouter>
                <BookingPage />
            </MemoryRouter>
        );

        expect(screen.getByRole('heading', { level: 1, name: /Book a Room/i })).toBeInTheDocument();

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        expect(screen.getByLabelText(/Select a room:/i)).toBeInTheDocument();
        expect(screen.getByPlaceholderText('Full Name')).toBeInTheDocument();
    });

    it('displays an error when room fetch fails', async () => {
        getAllRooms.mockRejectedValue(new Error('Failed to fetch rooms'));

        render(
            <MemoryRouter>
                <BookingPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.getByText(/Failed to fetch rooms/i)).toBeInTheDocument();
        });
    });

    it('renders room selector with correct options', async () => {
        render(
            <MemoryRouter>
                <BookingPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        const roomSelect = screen.getByLabelText(/Select a room:/i);

        expect(roomSelect).toHaveValue('1'); // Default selected value
        expect(screen.getByText('Conference Room')).toBeInTheDocument();
        expect(screen.getByText('Meeting Room')).toBeInTheDocument();
    });

    it('handles booking failure gracefully', async () => {
        const alertSpy = jest.spyOn(window, 'alert');
        createBooking.mockRejectedValue({
            response: { data: 'Time slot already booked' }
        });

        render(
            <MemoryRouter>
                <BookingPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        fireEvent.change(screen.getByPlaceholderText('Full Name'), {
            target: { value: 'John Doe' }
        });

        fireEvent.click(screen.getByText(/Create Booking/i));

        await waitFor(() => {
            expect(alertSpy).toHaveBeenCalledWith(expect.stringContaining('Failed to create booking'));
        });

        expect(mockNavigate).not.toHaveBeenCalled();
    });
});