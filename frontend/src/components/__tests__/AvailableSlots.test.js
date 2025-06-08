import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import AvailableSlots from '../AvailableSlots';
import { getAvailableSlots } from '../../api/bookings';
import { getAllRooms } from '../../api/rooms';

jest.mock('../../api/bookings');
jest.mock('../../api/rooms');

describe('AvailableSlots', () => {
    const mockRooms = {
        content: [
            { id: 1, name: 'Conference Room' },
            { id: 2, name: 'Meeting Room' }
        ]
    };

    const mockSlots = [
        { startTime: '09:00', endTime: '10:00', booked: false },
        { startTime: '10:00', endTime: '11:00', booked: true },
        { startTime: '11:00', endTime: '12:00', booked: false }
    ];

    beforeEach(() => {
        getAllRooms.mockResolvedValue(mockRooms);
        getAvailableSlots.mockResolvedValue(mockSlots);
    });

    afterEach(() => {
        jest.resetAllMocks();
    });

    it('renders loading state initially', () => {
        render(<AvailableSlots roomId={1} />);
        expect(screen.getByText(/Loading room information/i)).toBeInTheDocument();
    });

    it('displays room information after loading', async () => {
        render(<AvailableSlots roomId={1} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading room information/i)).not.toBeInTheDocument();
        });

        expect(screen.getByText(/Room id: 1/i)).toBeInTheDocument();
        expect(screen.getByRole('button', { name: /Get Slots/i })).toBeInTheDocument();
        expect(screen.getByRole('button', { name: /Get Slots/i })).toBeDisabled();
    });

    it('displays appropriate message when no slots are available', async () => {
        getAvailableSlots.mockResolvedValue([]);

        render(<AvailableSlots roomId={1} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading room information/i)).not.toBeInTheDocument();
        });

        const dateInput = document.querySelector('input[type="date"]');
        fireEvent.change(dateInput, { target: { value: '2024-06-20' } });
        fireEvent.click(screen.getByRole('button', { name: /Get Slots/i }));

        await waitFor(() => {
            expect(screen.getByText(/No slots available for the selected date/i)).toBeInTheDocument();
        });
    });

    it('handles API error during slot fetch', async () => {
        getAvailableSlots.mockRejectedValue(new Error('Failed to fetch slots'));

        render(<AvailableSlots roomId={1} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading room information/i)).not.toBeInTheDocument();
        });

        const dateInput = document.querySelector('input[type="date"]');
        fireEvent.change(dateInput, { target: { value: '2024-06-20' } });
        fireEvent.click(screen.getByRole('button', { name: /Get Slots/i }));

        await waitFor(() => {
            expect(screen.getByText(/Failed to fetch available slots/i)).toBeInTheDocument();
        });
    });
});