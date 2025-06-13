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

    it('handles date and time input changes', async () => {
        render(<BookingForm onSubmit={jest.fn()} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        // Test start hour change - find by name
        const startHourSelect = screen.getByDisplayValue('9:00');
        fireEvent.change(startHourSelect, { target: { value: '14:00' } });

        // Test end hour change
        const endHourSelect = screen.getByDisplayValue('10:00');
        fireEvent.change(endHourSelect, { target: { value: '15:00' } });

        // Verify the changes took effect
        expect(startHourSelect.value).toBe('14:00');
        expect(endHourSelect.value).toBe('15:00');
    });

    it('handles comment input change', async () => {
        render(<BookingForm onSubmit={jest.fn()} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        const commentInput = screen.getByPlaceholderText('Comment');
        fireEvent.change(commentInput, { target: { name: 'comment', value: 'Test comment' } });

        expect(commentInput.value).toBe('Test comment');
    });

    it('handles room selection change', async () => {
        const mockRooms = {
            content: [
                { id: 1, name: 'Conference Room' },
                { id: 2, name: 'Meeting Room' }
            ]
        };
        getAllRooms.mockResolvedValueOnce(mockRooms);

        render(<BookingForm onSubmit={jest.fn()} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        const roomSelect = screen.getByLabelText(/Select a room:/i);
        fireEvent.change(roomSelect, { target: { name: 'roomId', value: '2' } });

        expect(roomSelect.value).toBe('2');
    });

    it('sets default values correctly when rooms are loaded', async () => {
        const mockRooms = {
            content: [
                { id: 1, name: 'Conference Room' },
                { id: 2, name: 'Meeting Room' }
            ]
        };
        getAllRooms.mockResolvedValueOnce(mockRooms);

        render(<BookingForm onSubmit={jest.fn()} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        const roomSelect = screen.getByLabelText(/Select a room:/i);
        expect(roomSelect.value).toBe('1'); // First room should be selected by default
    });

    it('handles successful form submission', async () => {
        const mockOnSubmit = jest.fn();
        const alertSpy = jest.spyOn(window, 'alert').mockImplementation(() => {});
        
        render(<BookingForm onSubmit={mockOnSubmit} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        fireEvent.change(screen.getByPlaceholderText('Full Name'), {
            target: { name: 'fio', value: 'John Doe' }
        });

        fireEvent.click(screen.getByText(/Create Booking/i));

        await waitFor(() => {
            expect(createBooking).toHaveBeenCalled();
            expect(mockOnSubmit).toHaveBeenCalledWith('ABC123');
            expect(alertSpy).toHaveBeenCalledWith('Booking created successfully!');
        });

        alertSpy.mockRestore();
    });

    it('handles error with statusText', async () => {
        const alertSpy = jest.spyOn(window, 'alert').mockImplementation(() => {});
        createBooking.mockRejectedValueOnce({
            response: { statusText: 'Bad Request' }
        });

        render(<BookingForm onSubmit={jest.fn()} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        fireEvent.change(screen.getByPlaceholderText('Full Name'), {
            target: { name: 'fio', value: 'John Doe' }
        });

        fireEvent.click(screen.getByText(/Create Booking/i));

        await waitFor(() => {
            expect(alertSpy).toHaveBeenCalledWith('Failed to create booking: Bad Request');
        });

        alertSpy.mockRestore();
    });

    it('handles error without response', async () => {
        const alertSpy = jest.spyOn(window, 'alert').mockImplementation(() => {});
        createBooking.mockRejectedValueOnce({
            message: 'Network Error'
        });

        render(<BookingForm onSubmit={jest.fn()} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        fireEvent.change(screen.getByPlaceholderText('Full Name'), {
            target: { name: 'fio', value: 'John Doe' }
        });

        fireEvent.click(screen.getByText(/Create Booking/i));

        await waitFor(() => {
            expect(alertSpy).toHaveBeenCalledWith('Failed to create booking: Network Error');
        });

        alertSpy.mockRestore();
    });

    it('handles room fetch error', async () => {
        getAllRooms.mockRejectedValueOnce(new Error('Failed to fetch'));

        render(<BookingForm onSubmit={jest.fn()} />);

        await waitFor(() => {
            expect(screen.getByText('Failed to fetch rooms')).toBeInTheDocument();
        });
    });
});