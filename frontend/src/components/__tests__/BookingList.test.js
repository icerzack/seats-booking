import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import BookingList from '../BookingList';
import { getBookingsByUser } from '../../api/bookings';

jest.mock('../../api/bookings');

describe('BookingList', () => {
    const mockBookings = [
        {
            id: 1,
            startTime: '2024-06-20T09:00:00',
            endTime: '2024-06-20T10:00:00',
            comment: 'Meeting with team'
        },
        {
            id: 2,
            startTime: '2024-06-21T14:00:00',
            endTime: '2024-06-21T15:00:00',
            comment: null
        }
    ];

    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('renders the bookings list header', async () => {
        render(<BookingList userCode="ABC123" />);
        expect(screen.getByText(/Your Bookings/i)).toBeInTheDocument();
    });

    it('shows a message when no bookings are found', async () => {
        getBookingsByUser.mockResolvedValueOnce([]);

        render(<BookingList userCode="EMPTY123" />);

        await waitFor(() => {
            expect(getBookingsByUser).toHaveBeenCalledWith('EMPTY123');
        });

        expect(screen.getByText(/No bookings found for this code/i)).toBeInTheDocument();
    });

    it('logs error when API call fails', async () => {
        const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
        getBookingsByUser.mockRejectedValueOnce(new Error('API error'));

        render(<BookingList userCode="ERROR123" />);

        await waitFor(() => {
            expect(consoleSpy).toHaveBeenCalledWith('Failed to fetch bookings:', expect.any(Error));
        });

        consoleSpy.mockRestore();
    });
});