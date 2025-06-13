import React from 'react';
import { render, screen, waitFor, fireEvent, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import BookingList from '../BookingList';
import { getBookingsByUser, deleteBooking, updateBooking } from '../../api/bookings';

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

    it('renders bookings when userCode is provided', async () => {
        getBookingsByUser.mockResolvedValueOnce(mockBookings);

        render(<BookingList userCode="ABC123" />);

        await waitFor(() => {
            expect(screen.getByText('Meeting with team')).toBeInTheDocument();
            expect(screen.getByText('None')).toBeInTheDocument(); // For booking without comment
        });

        expect(screen.getAllByText(/Booking ID:/)).toHaveLength(2);
        expect(screen.getAllByText(/Start Time:/)).toHaveLength(2);
        expect(screen.getAllByText(/End Time:/)).toHaveLength(2);
    });

    it('does not fetch bookings when userCode is null', () => {
        render(<BookingList userCode={null} />);
        expect(getBookingsByUser).not.toHaveBeenCalled();
    });

    it('starts editing mode when Edit button is clicked', async () => {
        getBookingsByUser.mockResolvedValueOnce(mockBookings);

        render(<BookingList userCode="ABC123" />);

        await waitFor(() => {
            expect(screen.getByText('Meeting with team')).toBeInTheDocument();
        });

        const editButton = screen.getAllByText('Edit')[0];
        fireEvent.click(editButton);

        expect(screen.getByDisplayValue('Meeting with team')).toBeInTheDocument();
        expect(screen.getByText('Save')).toBeInTheDocument();
        expect(screen.getByText('Cancel')).toBeInTheDocument();
    });

    it('cancels editing when Cancel button is clicked', async () => {
        getBookingsByUser.mockResolvedValueOnce(mockBookings);

        render(<BookingList userCode="ABC123" />);

        await waitFor(() => {
            expect(screen.getByText('Meeting with team')).toBeInTheDocument();
        });

        // Start editing
        const editButton = screen.getAllByText('Edit')[0];
        fireEvent.click(editButton);

        // Cancel editing
        const cancelButton = screen.getByText('Cancel');
        fireEvent.click(cancelButton);

        expect(screen.queryByText('Save')).not.toBeInTheDocument();
        expect(screen.getAllByText('Edit').length).toBeGreaterThan(0);
    });

    it('updates booking when Save button is clicked', async () => {
        getBookingsByUser.mockResolvedValueOnce(mockBookings);
        updateBooking.mockResolvedValueOnce({});
        getBookingsByUser.mockResolvedValueOnce(mockBookings); // For refetch

        render(<BookingList userCode="ABC123" />);

        await waitFor(() => {
            expect(screen.getByText('Meeting with team')).toBeInTheDocument();
        });

        // Start editing
        const editButton = screen.getAllByText('Edit')[0];
        fireEvent.click(editButton);

        // Change comment
        const commentInput = screen.getByDisplayValue('Meeting with team');
        await act(async () => {
            await userEvent.clear(commentInput);
            await userEvent.type(commentInput, 'Updated meeting');
        });

        // Save
        const saveButton = screen.getByText('Save');
        await act(async () => {
            fireEvent.click(saveButton);
        });

        await waitFor(() => {
            expect(updateBooking).toHaveBeenCalledWith(1, {
                ...mockBookings[0],
                comment: 'Updated meeting'
            });
        });
    });

    it('handles update error', async () => {
        const alertSpy = jest.spyOn(window, 'alert').mockImplementation(() => {});
        const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
        
        getBookingsByUser.mockResolvedValueOnce(mockBookings);
        updateBooking.mockRejectedValueOnce(new Error('Update failed'));

        render(<BookingList userCode="ABC123" />);

        await waitFor(() => {
            expect(screen.getByText('Meeting with team')).toBeInTheDocument();
        });

        // Start editing and save
        const editButton = screen.getAllByText('Edit')[0];
        fireEvent.click(editButton);
        
        const saveButton = screen.getByText('Save');
        await act(async () => {
            fireEvent.click(saveButton);
        });

        await waitFor(() => {
            expect(consoleSpy).toHaveBeenCalledWith('Failed to update booking:', expect.any(Error));
            expect(alertSpy).toHaveBeenCalledWith('Failed to update booking. Please try again.');
        });

        alertSpy.mockRestore();
        consoleSpy.mockRestore();
    });

    it('deletes booking when Delete button is clicked', async () => {
        getBookingsByUser.mockResolvedValueOnce(mockBookings);
        deleteBooking.mockResolvedValueOnce({});

        render(<BookingList userCode="ABC123" />);

        await waitFor(() => {
            expect(screen.getByText('Meeting with team')).toBeInTheDocument();
        });

        const deleteButton = screen.getAllByText('Delete')[0];
        await act(async () => {
            fireEvent.click(deleteButton);
        });

        await waitFor(() => {
            expect(deleteBooking).toHaveBeenCalledWith(1);
        });
    });

    it('handles delete error', async () => {
        const alertSpy = jest.spyOn(window, 'alert').mockImplementation(() => {});
        const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
        
        getBookingsByUser.mockResolvedValueOnce(mockBookings);
        deleteBooking.mockRejectedValueOnce(new Error('Delete failed'));

        render(<BookingList userCode="ABC123" />);

        await waitFor(() => {
            expect(screen.getByText('Meeting with team')).toBeInTheDocument();
        });

        const deleteButton = screen.getAllByText('Delete')[0];
        await act(async () => {
            fireEvent.click(deleteButton);
        });

        await waitFor(() => {
            expect(consoleSpy).toHaveBeenCalledWith('Failed to delete booking:', expect.any(Error));
            expect(alertSpy).toHaveBeenCalledWith('Failed to delete booking. Please try again.');
        });

        alertSpy.mockRestore();
        consoleSpy.mockRestore();
    });

    it('prevents multiple delete operations', async () => {
        getBookingsByUser.mockResolvedValueOnce(mockBookings);
        deleteBooking.mockImplementation(() => new Promise(resolve => setTimeout(resolve, 100)));

        render(<BookingList userCode="ABC123" />);

        await waitFor(() => {
            expect(screen.getByText('Meeting with team')).toBeInTheDocument();
        });

        const deleteButton = screen.getAllByText('Delete')[0];
        
        // First click
        fireEvent.click(deleteButton);
        expect(screen.getAllByText('Deleting...').length).toBeGreaterThan(0);
        
        // Second click should be ignored
        fireEvent.click(deleteButton);
        expect(deleteBooking).toHaveBeenCalledTimes(1);
    });
});