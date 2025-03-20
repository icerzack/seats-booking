package vasilkov.seats_booking_backend.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PagedModel;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vasilkov.seats_booking_backend.entity.Room;
import vasilkov.seats_booking_backend.entity.repository.RoomRepository;

@RestController
@RequestMapping("rooms")
@RequiredArgsConstructor
public class RoomController {

    private final RoomRepository roomRepository;
    private final ObjectMapper objectMapper;

    @GetMapping
    public PagedModel<Room> getAll(@ParameterObject Pageable pageable) {
        Page<Room> rooms = roomRepository.findAll(pageable);
        return new PagedModel<>(rooms);
    }
}
