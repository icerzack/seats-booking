package vasilkov.seats_booking_backend.api;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import vasilkov.seats_booking_backend.entity.Room;
import vasilkov.seats_booking_backend.entity.repository.RoomRepository;

import java.util.Collections;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class RoomControllerTest {

    @Mock
    private RoomRepository roomRepository;

    @InjectMocks
    private RoomController roomController;

    @Test
    void getAll_shouldReturnPagedModel() {
        // Arrange
        Pageable pageable = PageRequest.of(0, 10);
        Room room = new Room();
        Page<Room> page = new PageImpl<>(Collections.singletonList(room), pageable, 1);

        when(roomRepository.findAll(pageable)).thenReturn(page);

        // Act
        roomController.getAll(pageable);
        verify(roomRepository, times(1)).findAll(pageable);
    }
}