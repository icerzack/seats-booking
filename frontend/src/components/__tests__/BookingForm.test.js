import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import BookingForm from '../BookingForm';
import { createBooking } from '../../api/bookings';
import { getAllRooms } from '../../api/rooms';

jest.mock('../../api/bookings');
jest.mock('../../api/rooms');

describe('BookingForm', () => {
    const mockRooms = {
        content: [
            { id: 1, name: 'Room 1' },
            { id: 2, name: 'Room 2' }
        ]
    };

    const mockOnSubmit = jest.fn();

    beforeEach(() => {
        getAllRooms.mockResolvedValue(mockRooms);
        createBooking.mockResolvedValue({ data: { code: 'ABC123' } });
    });

    afterEach(() => {
        jest.resetAllMocks();
    });

    it('renders the booking form with loading state initially', () => {
        render(<BookingForm onSubmit={mockOnSubmit} />);
        expect(screen.getByText(/Loading rooms.../i)).toBeInTheDocument();
    });

    it('renders the form with room options after loading', async () => {
        render(<BookingForm onSubmit={mockOnSubmit} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        expect(screen.getByLabelText(/Select a room:/i)).toBeInTheDocument();
        expect(screen.getByDisplayValue('Room 1')).toBeInTheDocument();
        expect(screen.getByPlaceholderText('Full Name')).toBeInTheDocument();
        expect(screen.getByPlaceholderText('Comment')).toBeInTheDocument();
        expect(screen.getAllByRole('combobox')).toHaveLength(3); // room select, start hour, end hour
        expect(screen.getAllByRole('button')).toHaveLength(1);
        expect(screen.getByText(/Create Booking/i)).toBeInTheDocument();
    });

    it('handles API error during form submission', async () => {
        const consoleSpy = jest.spyOn(window, 'alert').mockImplementation(() => {});
        createBooking.mockRejectedValue({ response: { data: 'Server error' } });

        render(<BookingForm onSubmit={mockOnSubmit} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        fireEvent.click(screen.getByText(/Create Booking/i));

        await waitFor(() => {
            expect(consoleSpy).toHaveBeenCalledWith(expect.stringContaining('Failed to create booking'));
            expect(mockOnSubmit).not.toHaveBeenCalled();
        });

        consoleSpy.mockRestore();
    });
});