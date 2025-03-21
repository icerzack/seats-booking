package vasilkov.seats_booking_backend.api.response;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserCodeDTO {
    private String code;
}
