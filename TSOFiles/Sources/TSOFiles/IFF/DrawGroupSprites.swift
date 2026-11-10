import Foundation

extension IFFFile {
    /// Decodes a drawing group sprite's frame from this file, the one the drawing group is in,
    /// as FreeSO's `DGRPSprite.GetWorldTexture` finds it: the `SPR2` with the sprite's ID, else
    /// the `SPR#`, each decoded with the palette it names from this file. `nil` when neither
    /// chunk exists.
    public func decodedFrame(for sprite: DGRP.Sprite) throws(SpriteError) -> SpriteImage? {
        guard let id = UInt16(exactly: sprite.spriteID), let frame = Int(exactly: sprite.frameIndex) else { return nil }
        do {
            if let sprite2 = try chunk(SPR2.self, id: id) {
                guard sprite2.frames.indices.contains(frame) else { throw SpriteError.noSuchFrame(frame) }
                let palette = try chunk(PALT.self, id: sprite2.frames[frame].paletteID)
                return try sprite2.decode(frameAt: frame, palette: palette)
            }
            if let sprite1 = try chunk(SPR.self, id: id) {
                return try sprite1.decode(frameAt: frame, palette: try chunk(PALT.self, id: sprite1.paletteID))
            }
            return nil
        } catch let error as SpriteError {
            throw error
        } catch {
            throw .unreadableChunk(String(describing: error))
        }
    }
}
